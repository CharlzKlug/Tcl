package require lambda
proc fibonacci_generate {} {
    yield
    set prev 0
    set fib 1
    while 1 {
	yield $fib
	lassign [list $fib [incr fib $prev]] prev fib
    }
}

proc filter_proc {producer} {
    yield
    while 1 {
	set number [$producer]
	if {[expr {$number & 1}] == 0} {
	    yield $number
	}
    }
}

# coroutine fib_producer fibonacci_generate
# coroutine print_consumer while 1 {puts [yield]}
# coroutine squarer {*}[lambda {} {
#     set val [yield]
#     while 1 {
# 	set val [yield [expr {$val*$val}]]
#     }
# }]

coroutine fib_producer3 fibonacci_generate
coroutine even_fibs2 {*}[lambda {producer consumer} {
    yield
    while 1 {
	incr seq
	set number [$producer]
	if {[expr {$number & 1}] == 0} {
	    yieldto $consumer "Position: $seq"
	    yieldto $consumer "Number: $number"
	}
    }
}] fib_producer3 print_consumer
