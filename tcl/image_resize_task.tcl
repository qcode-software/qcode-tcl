namespace eval qc {
    namespace export \
        image_resize_task_add \
        image_resize_task_process
}

proc qc::image_resize_task_add {
    file_id
    cache_dir
    width
    height
    {autocrop false}
} {
    #| Add a new resize task for an image in the database.

    db_0or1row {
        select
        row_id

        from
        image_resize_task

        where
        file_id=:file_id
        and cache_dir=:cache_dir
        and autocrop=:autocrop
        and task_state = 'QUEUED'
        and (
             (
              width=:width
              and height<=:height
             )
             or (
                 width<=:width
                 and height=:height
             )
        )
    } {
        # Image hasn't been queued at this height and width for the cache directory.
        set row_id [qc::db_seq "row_id_seq"]
        set task_state "QUEUED"
        set date_added [qc::cast timestamptz "now"]

        db_dml "
            insert into
            image_resize_task
            [qc::sql_insert {*}{
                row_id
                file_id
                cache_dir
                height
                width
                date_added
                task_state
                autocrop
            }]
        "
    }

    return $row_id
}

proc qc::image_resize_task_process { row_id } {
    #| Resize and cache the image from the task queue.

    db_trans {
        db_0or1row {
            select
            i.file_id,
            i.cache_dir,
            i.height,
            i.width,
            i.autocrop,
            f.mime_type

            from
            image_resize_task i
            join file f using (file_id)

            where
            i.row_id=:row_id
            and i.task_state = 'QUEUED'

            for update
        } {
            error "No queued image resize task exists for row ${row_id}."
        }

        set date_processed [qc::cast timestamptz "now"]

        ::try {
            set task_state "PROCESSED"

            if { ! [qc::_image_cache_original_exists $cache_dir $file_id] } {
                # Cache the original image.
                qc::_image_cache_original_create $cache_dir $file_id
            }

            if { $mime_type eq "*/*" } {
                set mime_type [qc::mime_type_guess \
                                   [qc::_image_cache_original_file \
                                        $cache_dir $file_id]]
            }

            if { $mime_type ne "image/svg+xml" } {
                qc::_image_cache_create \
                    $cache_dir \
                    $file_id \
                    $mime_type \
                    $width \
                    $height \
                    $autocrop
            }

        } on error [list message options] {
            set task_state "ERROR"

            error \
                $message \
                [dict get $options -errorinfo] \
                [dict get $options -errorcode]
        } finally {
            db_dml "
                update
                image_resize_task

                set
                [qc::sql_set {*}{
                    task_state
                    date_processed
                }]

                where
                row_id=:row_id
            "
        }
    }
}
