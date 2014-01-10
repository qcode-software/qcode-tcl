
package require doc
namespace eval qc {
    namespace export schema_update
}

proc qc::schema_update {version code} {
    #| Run the code if it applies to the current schema in order to bring the schema up to the next version.
    db_trans {
	db_1row {select version as current_version from schema for update}
	if { $current_version == $version } {
	    log "Updating schema version $version ..."
	    uplevel 1 $code
	    incr version
	    db_dml {update schema set version=:version}
	    log "Schema updated to version $version"
	}
    }
}

doc qc::schema_update {
    Examples {
	schema_update 19 {
	    db_dml { alter table product add column ean bigint }
	}
	
    }
}
