proc on_accept {so client_ip client_port} {
    set slave [interp create -safe]
    set cmdlimit [$slave eval {info cmdcount}]
    $slave limit command -value [incr cmdlimit 3]
    $slave limit time -seconds [expr {[clock seconds] + 60}]
    chan configure $so -buffering line -encoding utf-8 -blocking 0 -translation crlf
    chan event $so readable [list on_read $slave $so $client_port]
}

proc on_read {slave so client_port} {
    set n [gets $so line]
    if {$n >= 0} {
	set status [catch {$slave eval [list expr $line]} result]
	puts $so $result
	if {$status &&
	    [lindex $::errorCode 0] eq "TCL" &&
	    [lindex $::errorCode 1] eq "LIMIT"} {
	    close $so
	    interp delete $slave
	}
    } elseif {[chan eof $so]} {
	close $so
	interp delete $slave
    }
}
