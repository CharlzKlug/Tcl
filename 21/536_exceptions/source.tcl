# proc accumulate {} {
#     set i 0
#     while {1} {
# 	incr i [::tcl::mathop::+ {*}[yieldto return $i]]
#     }
# }

proc accumulate {} {
    set sum 0
    while {1} {
	if {[catch {
	    set part_sum [::tcl::mathop::+ {*}[yieldto return $sum]]
	} result ropts]} {
	    set part_sum [::tcl::mathop::+ {*}[yieldto return -options $ropts $result]]
	}
	incr sum $part_sum
    }
}

coroutine accumulator accumulate
