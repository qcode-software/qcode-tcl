qc::db_trans
============

part of [Database API](../db.md)

Usage
-----
`db_trans code ?on_error_code?`

Description
-----------
Execute code within a database transaction.
    Rollback on database or tcl error.

Examples
--------
```tcl

db_trans {
    db_dml {update account set balance=balance-10 where account_id=1}
    db_dml {update account set balance=balance+10 where account_id=2}
}

db_trans {
    # Select for update
    db_1row {select order_state from sales_order where order_number=123 for update}
    if { ![string equal $order_state OPEN ] } {
    # Throw error and ROLLBACK
    error "Can't invoice sales order $order_number because it is not OPEN"
    }
    # Perform action that requires order to be OPEN
    invoice_sales_order 123
}

db_trans {
    blow-up
} {
    # cleanup here
}

```

----------------------------------
*[Qcode Software Limited] [qcode]*

[qcode]: http://www.qcode.co.uk "Qcode Software"