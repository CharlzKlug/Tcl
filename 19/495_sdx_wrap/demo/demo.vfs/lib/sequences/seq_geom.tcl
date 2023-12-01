# seq_geom.tcl
namespace eval seq {
    proc geom_term {a r n} {
	return [expr {$a * $r**($n-1)}]
    }
}
