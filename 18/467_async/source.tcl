proc on_read so {
    set s [read $so]
    if {[string length $so] == 0} {
	if {[eof $so]} {
	    close $so
	    set ::done 1
	}
	return
    }
    puts $s
}

proc on_write so {
    puts $so "GET http://www.example.com HTTP/1.1\n"
    chan event $so writable {}
    chan close $so write
}

# set so [socket -async www.example.com 80]
# fconfigure $so -blocking 0 -encoding utf-8 -translation crlf -buffering line
# chan event $so readable [list on_read $so]
# chan event $so writable [list on_write $so]
# vwait ::done
