oo::class create Lgen {
    variable List
    variable Index
    constructor {l} {
	set List $l
	set Index -1
    }
    method next {} {
	incr Index
	if {$Index >= [llength $List]} {
	    set Index 0
	}
	return [lindex $List $Index]
    }
}
