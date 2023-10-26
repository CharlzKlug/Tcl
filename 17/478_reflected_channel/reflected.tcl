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

proc ::bureaucrat::write {chan bytes} {
    variable channels
    if {[string length $bytes] == 0} {
	return 0
    }
    dict with channels($chan) {
	if {$InFlight} {
	    if {$Blocking} {
		return -code error EAGAIN
	    } else {
		return -code error EAGAIN
	    }
	}
	set InFlight 1
	after $Delay [list [namespace current]::delayed_receive $chan $bytes]
    }
    return [string length $bytes]
}

proc ::bureaucrat::delayed_receive {chan bytes} {
    variable channels
    if {! [info exists channels($chan)]} {
	return;
    }
    dict with channels($chan) {
	if {$State ne "OPEN"} {
	    return
	}
	append Data $bytes
	set InFlight 0
    }
    notify $chan read
    notify $chan write
}

proc ::bureaucrat::read {chan count} {
    variable channels
    dict with channels($chan) {
	if {[string length $Data] == 0} {
	    if {$Blocking} {
		return -code error EAGAIN
	    } else {
		return -code error EAGAIN
	    }
	    set bytes [string range $Data 0 $count-1]
	    set Data [string range $Data $count+1 end]
	}
	notify $chan read
	return $bytes
    }
}
