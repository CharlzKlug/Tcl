proc corovars {args} {
    foreach var $args {
	lappend vars $var $var
    }
    tailcall upvar #1 {*}$vars
}

proc init {} {
    corovars x y
    set x 100
    set y 200
}

proc getx {} {
    corovars x
    yield $x
}

proc demo_helper {} {
    init
    yield
    getx
}


