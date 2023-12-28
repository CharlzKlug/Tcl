proc yieldm {{val {}}} {
    yieldto return -level 0 $val
}

proc accumulate {} {
    set sum 0
    while {1} {
	puts "Before: $sum"
	set intermidiate [yieldm $sum]
	puts "Intermidiate value: $intermidiate"
	incr sum [::tcl::mathop::+ {*}$intermidiate]
	puts "After: $sum"
    }
}

proc test-yield {} {
    set i 0
    while {1} {
	set t [yield $i]
	puts "T is $t"
    }
}
