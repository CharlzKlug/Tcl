set dir /home/charlzk/Projects/TclVFS/index/library
source Projects/TclVFS/index/pkgIndex.tcl
package require vfs
package require tcl::chan::variable
namespace eval memfs {
    namespace ensemble create -parameters {fs_id} -subcommands {
	access createdirectory deletefile fileattributes
	matchindirectory open removedirectory stat utime
    }
}

proc memfs::posix_error {err} {
    if {![string is integer -strict $err]} {
	set err [::vfs::posixError $err]
    }
    vfs::filesystem posixerror $err
}
