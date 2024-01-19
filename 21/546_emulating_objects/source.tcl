proc yieldm {{val {}}} {
    yieldto return -level 0 $val
}

proc corovars {args} {
    foreach var $args {
	lappend vars $var $var
    }
    tailcall upvar #1 {*}$vars
}

proc plus {args} {
    corovars acc
    set acc [tcl::mathop::+ $acc {*}$args]
}

proc mul {args} {
    corovars acc
    set acc [tcl::mathop::* $acc {*}$args]
}

proc calculator {} {
    set acc 0
    set args [yieldm]
    while 1 {
	if {[llength $args] == 0} {
	    set args [yieldm $acc]
	} else {
	    switch -exact [lindex $args 0] {
		mul -
		plus {
		    {*}$args
		    set args [yieldm]
		}
		default {
		    set args [yieldto error "Unknown method [lindex $args 0]"]
		}
	    }
	}
    }
}
