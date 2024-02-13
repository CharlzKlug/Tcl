set init_script {
    package require http
    proc fetch_url {url} {
	set tok [http::geturl $url]
	try {
	    switch -exact -- [http::status $tok] {
		ok { return [http::data $tok] }
		eof { error "Server closed connection." }
		default { error "Unknown error retrieving $url" }
	    }
	} finally {
	    http::cleanup $tok
	}
    }
}
