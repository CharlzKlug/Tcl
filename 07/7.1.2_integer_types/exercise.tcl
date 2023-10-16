proc assert {bool_value error_message} {
    if {$bool_value} {
	error $error_message
    }
}

proc minute_of_day {time_of_day} {
    set result [scan $time_of_day %d:%d hours minutes]
    assert [expr {$result <2}] "Error!"
    return [expr {$hours * 60 + $minutes}]
}
