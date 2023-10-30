set http_req "GET / HTTP/1.1\nHost:httpforever.com\n"
set so [socket httpforever.com 80]
chan configure $so -encoding utf-8 -translation crlf -buffering line
puts $so $http_req
close $so write
puts [read $so]
close $so
