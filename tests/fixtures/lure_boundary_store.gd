extends ProgressStore

var calls := 0
var failures: Array[int] = []
var stop_call := 0
var stop_after := false
var directory := ""
var seed_attempts: Array[Dictionary] = []


func save_data(hub: Dictionary, replace_existing: bool = false) -> Error:
	calls += 1
	seed_attempts.append(hub.get("visit_seed", {}).duplicate(true))
	if calls == stop_call and not stop_after:
		_wait_for_termination()
	if calls in failures:
		return ERR_FILE_CANT_WRITE
	var error := super.save_data(hub, replace_existing)
	if calls == stop_call and stop_after and error == OK:
		_wait_for_termination()
	return error


func _wait_for_termination() -> void:
	var file := FileAccess.open(directory.path_join("boundary.ready"), FileAccess.WRITE)
	file.store_string(str(calls))
	file.close()
	# The supervising test kills only this child process at a known save boundary.
	OS.delay_msec(30000)
