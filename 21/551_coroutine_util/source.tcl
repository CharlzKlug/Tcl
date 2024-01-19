package require coroutine

proc proxy {from to} {
    while {[coroutine::util gets $from data] >= 0} {
	puts $to $data
    }
}

coroutine atob proxy $chan_a $chan_b
coroutine btoa proxy $chan_b $chan_a
