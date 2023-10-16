proc signum {n} {
    if {$n < 0} {
	return -1
    } elseif {$n == 0} {
	return 0
    } else {
	return 1
    }
}

puts [signum -5]
