# demo.tcl
package provide app-demo 1.0
package require sequences

if {[catch {
    switch -exact -- [lindex $argv 0] {
	hello { hello }
	arith { seq::arith_term {*}[lrange $argv 1 end] }
	geom { seq::geom_term {*}[lrange $argv 1 end] }
	default {
	    error "Unknown or missing command: must be hello, arith, geom"
	}
    }
} result]} {
    puts stderr $result
    exit 1
} else {
    if {$result ne ""} {
	puts stdout $result
    }
}
