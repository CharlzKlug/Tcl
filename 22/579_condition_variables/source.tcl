package require Thread
tsv::set shared_data urls {}
set mutex [thread::mutex create]
tsv::set shared_data mutex $mutex
set cond [thread::cond create]
tsv::set shared_data cond $cond

set worker_script {
    package require http
    package require fileutil
    proc url_to_file {url} {
	return [file join \
		    [fileutil::tempdir] \
		    [file rootname [file tail $url]]_content.html]
    }
set mutex [tsv::get shared_data mutex]
set cond [tsv::get shared_data cond]
while {1} {
    thread::mutex lock $mutex
    while {[tsv::llength shared_data urls] == 0} {
	thread::cond wait $cond $mutex
    }
    set url [tsv::lpop shared_data urls]
    thread::mutex unlock $mutex
    set tok [http::geturl $url]
    fileutil::writeFile [url_to_file $url] [http::data $tok]
    http::cleanup $tok
}
}
