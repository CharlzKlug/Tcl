proc print_dir_size {dir} {
    set total 0
    foreach fn [glob -nocomplain [file join $dir *]] {
	incr total [file size $fn]
	if {[file isdirectory $fn]} {
	    incr total [print_dir_size $fn]
	}
    }
    puts "$dir: $total"
    after idle after 0 [info coroutine]
    yield
    return $total
}
