package require lambda
package require fileutil

set nested {0 {1 {2 3}} {4 5}}

proc iterate {l cmd} {
    set n [llength $l]
    if {$n > 1} {
	foreach e $l {
	    iterate $e $cmd
	}
    } elseif {[llength $l] == 1} {
	{*}$cmd [lindex $l 0]
    }
}

proc iterator_wrapper {collection} {
    yield
    iterate $collection yield
}
coroutine iterator iterator_wrapper $nested

proc yield_one {fname} {
    yield [file join [pwd] $fname]
    return 0
}
proc file_iterator {dir} {
    yield
    fileutil::find $dir yield_one
}
