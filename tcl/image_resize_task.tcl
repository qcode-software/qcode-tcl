package require crc32

namespace eval qc {
    namespace export \
        image_resize_task_add \
        image_resize_task_process
}

proc qc::image_resize_task_add {args} {
    #| Add a new resize task for an image in the database.

    qc::args $args {*}{
        -autocrop
        -mime_type "*/*"
        -cache_dir ""
        --
        file_id
        width
        height
    }

    default autocrop false

    if { $cache_dir eq "" } {
        set cache_dir [ns_pagepath]/image
    }

    if { $mime_type eq "*/*" } {
        db_1row {
            select
            mime_type

            from
            file

            where
            file_id=:file_id
        }
    }

    db_trans {
        qc::db_advisory_trans_lock image_resize_task add

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
            and mime_type=:mime_type
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
                    mime_type
                }]
            "
        }
    }

    return $row_id
}
