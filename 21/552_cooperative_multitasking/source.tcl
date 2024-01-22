package require coroutine
namespace eval task {
    variable tasks {}
}

proc task::task {script} {
    variable next_id
    variable tasks
    variable tasks_added

    set task_id [namespace current]::task#[incr next_id]
    dict set tasks $task_id State INIT
    dict set tasks $task_id Messages {}
    set tasks_added 1
    coroutine $task_id apply {script {
	yield
	try $script finally {task::cleanup [task::myself]}
    }} $script
    wakeup_dispatcher
    return $task_id
}

proc task::myself {} {
    variable tasks
    set me [info coroutine]
    if {[dict exists $tasks $me]} {
	return $me
    }
    error "Not running in a task."
}

proc task::cleanup {task_id} {
    variable tasks
    if {[dict exists $tasks $task_id]} {
	catch {rename $task_id ""}
	dict unset tasks $task_id
    }
}
