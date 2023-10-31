proc on_accept {so client_ip client_port} {
    puts "I have new connection!"
    chan configure $so -buffering line -encoding utf-8 -blocking 0 -translation crlf
    chan event $so readable [list on_read $so $client_port]
}

proc on_read {so client_port} {
    set n [gets $so line]
    if {$n > 0} {
	puts $so "$client_port: [string reverse $line]"
	return
    } elseif {$n == 0} {
	exit 0
    } elseif {[chan eof $so]} {
	close $so
    }
}

puts "Starting server..."
set listener [socket -server on_accept -myaddr 127.0.0.1 10042]
vwait forever
