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
	
