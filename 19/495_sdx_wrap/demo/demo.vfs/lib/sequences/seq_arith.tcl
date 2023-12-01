# seq_arith.tcl
namespace eval seq {
    proc arith_term {a i n} {
	return [expr {$a + ($n-1)*$i}]
    }
}

source [file join [file dirname [info script]] seq_geom.tcl]

package provide sequences 1.0
