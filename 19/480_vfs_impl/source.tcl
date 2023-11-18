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

proc memfs::Mount {mount_path} {
    set id [init_fs]
    vfs::filesystem mount $mount_path [list [namespace current] $id]
    vfs::RegisterMount $mount_path [list [namespace current]::Unmount $id]
    return $id
}

proc memfs::Unmount {fs_id mount_path} {
    variable file_systems
    if {![info exists file_systems($fs_id)]} {
	return
    }
    vfs::filesystem unmount $mount_path
    unset file_systems($fs_id)
    namespace delete $fs_id
    return
}

proc memfs::access {fs_id root relpath origpath mode} {
    switch -exact -- [node_type $fs_id $relpath] {
	"" { posix_error ENOENT }
	file { if {$mode & 1} { posix_error EACCES } }
	dir { }
    }
    return
}

proc memfs::createdirectory {fs_id root relpath origpath} {
    node_add_dir $fs_id [node_find $fs_id $relpath dir]
}

proc memfs::removedirectory {fs_id root relpath origpath recursive} {
    node_del_dir $fs_id [node_find $fs_id $relpath dir] $recursive
}

proc memfs::open {fs_id root relpath origpath mode perms} {
    variable file_systems

    set node_key [node_find $fs_id $relpath file]
    set exists [expr {[node_type $fs_id $relpath] ne ""}]
    set truncate 0
    switch -glob -- $mode {
	"" -
	r* {
	    if {! $exists} {
		posix_error ENOENT
	    }
	}
	a* -
	w* {
	    if {$exists} {
		if {[string index $mode 0] eq "w"} {
		    set truncate 1
		}
	    } else {
		node_add_file $fs_id $node_key
	    }
	}
	default {
	    error "Unsupported mode \"$mode\""
	}
    }
    set chan [node_add_channel $fs_id $node_key $truncate]
    set close_callback [list [namespace current]::node_close_handler \
			    $fs_id $node_key $chan]
    return [list $chan $close_callback]
}

proc memfs::deletefile {fs_id root relpath origpath} {
    node_del_file $fs_id [node_find $fs_id $relpath file]
}

proc memfs::utime {fs_id root relpath origpath atime mtime} {
    node_set_times $fs_id [node_find $fs_id $relpath] $atime $mtime
}
