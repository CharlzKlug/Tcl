proc bin2hex {args} {
    regexp -inline -all .. [binary encode hex [join $args ""]]
}

set bin [encoding convertto utf-8 [string repeat abcd 200]]

proc print_list {list} {
    foreach x $list {
	puts $x
    }
}

proc sorted_insert {l val} {
    set pos [lsearch -integer -bisect $l $val]
    if {$pos == -1 || [lindex $l $pos] != $val} {
	return [linsert $l [incr pos] $val]
    } else {
	return $l
    }
}
