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
} {
    #| Add a new resize task for an image in the database.

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
        }]
    "

    return $row_id
}

proc qc::image_resize_task_process { row_id } {
    #| Resize and cache the image.

    db_trans {
        db_0or1row {
            select
            file_id,
            cache_dir,
            height,
            width

            from
            image_resize_task

            where
            row_id=:row_id
            and task_state = 'QUEUED'

            for update
        } {
            error "No queued image resize task exists for row ${row_id}."
        }

        ::try {
            set task_state "PROCESSED"
            set date_processed [qc::cast timestamptz "now"]

            return [qc::image_data \
                        $cache_dir \
                        $file_id \
                        $width \
                        $height]
        } on error [list message options] {
            # TO DO - error immediately or log attempts and error if attempts > x?
            set task_state "ERROR"
            set date_processed ""

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
