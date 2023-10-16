#!/usr/bin/tclsh

namespace eval myapp {
    # Remember the directory we are located in.
    variable script_dir [file dirname [info script]]
    puts $script_dir
}

# Using apply only to not pollute global namespace with temporary variables
apply {paths {
    foreach path $paths {
	source [file join $::myapp::script_dir $path]
    }}} {a.tcl b.tcl}


