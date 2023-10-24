namespace eval ::bureaucrat {
    variable channels
    array set channels {}
}

proc ::bureaucrat::initialize {chan mode} {
    variable channels
    set channels($chan) {
	State OPEN
	Data {}
	InFlight 0
	Delay 100
	Blocking 1
	Watch {}
    }
    return {initialize finalize watch read write configure cget cgetall blocking}
}

proc ::bureaucrat::finalize {chan} {
    variable channels
    unset -nocomplain channels($chan)
}

proc ::bureaucrat::configure {chan optname optval} {
    variable channels
    if {$optname ne "-delay"} {
	error "Unknown option \"$optname\"."
    }
    dict set channels($chan) Delay $optval
    return
}

proc ::bureaucrat::cget {chan optname} {
    variable channels
    if {$optname ne "-delay"} {
	error "Unknown option \"$optname\"."
    }
    return [dict get $channels $chan Delay]
}

proc ::bureaucrat::cgetall {chan} {
    variable channels
    return [list -delay [dict get $channels $chan Delay]]
}
	
proc ::bureaucrat::blocking {chan mode} {
    variable channels
    dict set channels($chan) Blocking $mode
}

proc ::bureaucrat::watch {chan events} {
    variable channels
    set watched [dict get $channels($chan) Watch]
    dict set channels($chan) Watch $events
    if {"read" in $events && "read" ni $watched} {
	notify $chan read
    }
    if {"write" in $events && "write" ni $watched} {
	notify $chan write
    }
}

proc ::bureaucrat::notify {chan event} {
    variable channels
    dict with channels($chan) {
	if {$event ni $Watch} {
	    return
	}
	if {$event eq "read"} {
	    if {[string length $Data] == 0 && $State ne "EOF"} {
		return
	    }
	} else {
	    if {$State ne "OPEN"} return
	}
    }
    after idle [list after 0 [list chan postevent $chan $event]]
}
