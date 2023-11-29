namespace eval demo {}
package require starkit
set demo::run_mode [starkit::startup]
set demo::vfs_root [file dirname [file normalize [info script]]]

package require sequences
source [file join $demo::vfs_root hello.tcl]

puts "run_mode: $demo::run_mode"

switch -exact -- $demo::run_mode {
    sourced {}
    unwrapped -
    starkit -
    starpack {
	package require app-demo
    }
    default {
	error "Unknown run mode $demo::run_mode"
    }
}
