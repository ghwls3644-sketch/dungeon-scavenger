extends Node

const REVIEW := preload("res://tests/fixtures/results_readability_review.gd")
var failures: Array[String] = []
var directory := ""
var render := false
var captures := 0
var screens_checked := 0
var confirmations := 0


func _ready() -> void:
	directory = OS.get_environment("TEMP").path_join("dungeon-results-%d" % OS.get_process_id())
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--readability-directory="):
			directory = argument.trim_prefix("--readability-directory=")
	render = "--readability-render" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(directory)
	var screen: ExpeditionResultsScreen = REVIEW.SCREEN.instantiate()
	add_child(screen)
	screen.show()
	screen.settlement_requested.connect(func(): confirmations += 1)
	for case_name in REVIEW.CASES:
		var example := REVIEW.make_case(case_name)
		_expect(not example.is_empty(), "Cannot prepare case " + case_name)
		if example.is_empty():
			continue
		var hub: HubState = example.hub
		var before := hub.to_progress_data()
		var summary: Dictionary = example.settlement.get_cost_summary()
		screen.present_result(example.outcome, example.settlement)
		var expected_profit := "손익 계산 보류" if case_name == "unknown" else "%+d" % summary.profit
		_expect(screen.get_node("NextStep/NetIncome").text == expected_profit, case_name + " wrong profit/unknown display")
		_expect(screen.get_node("NextStep/Credit").text == "+%d" % summary.settlement_credit, "Wrong settlement deposit")
		_expect("현금 변화 %+d" % summary.cash_change in screen.get_node("NextStep/Totals").text and "정산 후 보유금 %d" % summary.money_after in screen.get_node("NextStep/Totals").text, "Wallet values mixed")
		if case_name == "paid_tools":
			_expect([summary.profit, summary.cash_change, summary.settlement_credit, summary.money_after] == [31, 16, 46, 116], "Paid/returned tools example changed")
			_expect("미사용 추가분 1개 반환" in screen.get_node("NextStep/Items").text and "미사용 1개 반환" in screen.get_node("NextStep/Items").text, "Returned tools absent")
		if case_name == "missed":
			_expect("의뢰 미달성 1/2 · 보상 0" in screen.get_node("NextStep/Overview").text, "Missed objective hidden")
		if case_name in ["legacy", "long_money"]:
			_expect("소급하지 않습니다" in screen.get_node("NextStep/Overview").text, "Legacy tax warning hidden")
		if case_name == "investment":
			_expect(summary.profit == 41 and summary.cash_change == -19 and summary.settlement_credit == 46, "Repair/investment distinction changed")
			_expect("영구 개선 투자 60" in screen.get_node("NextStep/Items").text, "Investment detail absent")
		for resolution in [Vector2i(1152, 648), Vector2i(1600, 900)]:
			get_window().size = resolution
			screen.present_result(example.outcome, example.settlement)
			await _frames(5)
			_check_layout(screen, case_name)
			_expect(not screen.get_node("NextStep/Items").visible and not screen.get_node("OutcomePanel").visible, "Details default obscures summary")
			await _capture(case_name + "-summary-%d" % resolution.x)
			var detail: Button = screen.get_node("NextStep/DetailButton")
			detail.grab_focus()
			_tap(KEY_ENTER)
			await _frames(3)
			var items: RichTextLabel = screen.get_node("NextStep/Items")
			_expect(items.is_visible_in_tree() and not screen.get_node("NextStep/Overview").visible, "Keyboard details failed")
			items.grab_focus()
			_tap(KEY_END)
			await _frames(3)
			var scroll := items.get_v_scroll_bar()
			_expect(scroll.max_value <= scroll.page or scroll.value > 0, "Keyboard could not reach detail end")
			_expect(items.get_global_rect().end.y <= screen.get_node("NextStep/Notice").global_position.y, "Details overlap notice/actions")
			if case_name in ["paid_tools", "failure", "unknown"]:
				await _capture(case_name + "-detail-end-%d" % resolution.x)
			_click(screen.get_node("NextStep/RecoveryButton"))
			await _frames(4)
			_expect(screen.get_node("OutcomePanel").is_visible_in_tree() and not screen.get_node("NextStep").visible, "Recovery view not isolated")
			_expect(get_viewport().get_visible_rect().encloses(screen.get_node("OutcomePanel").get_global_rect()), "Recovery view clips: %s / %s" % [screen.get_node("OutcomePanel").get_global_rect(), get_viewport().get_visible_rect()])
			_expect(screen.get_node("CloseRecovery").has_focus(), "Recovery close lacks keyboard focus")
			if case_name in ["protected", "failure"]:
				await _capture(case_name + "-recovery-%d" % resolution.x)
			_tap(KEY_ESCAPE)
			await _frames(3)
			_expect(screen.get_node("NextStep").visible and screen.get_node("NextStep/RecoveryButton").has_focus(), "Escape did not restore summary focus")
			_click(detail)
			await _frames(3)
			_expect(not items.visible, "Mouse detail collapse failed")
			_expect(confirmations == 0 and hub.to_progress_data() == before, "Inspection changed settlement/money")
			screens_checked += 1
	# Busy/error/no-result paths must keep the actionable status in view.
	screen.set_busy(true)
	_expect(screen.get_node("NextStep/SettleButton").disabled and screen.get_node("NextStep/QuitButton").disabled, "Busy buttons active")
	screen.set_busy(false)
	screen.set_status("저장하지 못했습니다. 정산 내역을 유지했습니다. 다시 시도하거나 종료할 수 있습니다.")
	await _frames(3)
	_check_layout(screen, "retry")
	await _capture("save-retry")
	screen.present_result(null, null)
	await _frames(3)
	_expect(screen.get_node("NextStep/SettleButton").disabled and screen.get_node("NextStep/QuitButton").has_focus(), "Missing result can be confirmed")
	var report := {"passed": failures.is_empty(), "cases": REVIEW.CASES, "screens_checked": screens_checked, "captures": captures, "failures": failures}
	var file := FileAccess.open(directory.path_join("results-readability.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t") + "\n")
	file.close()
	if failures.is_empty():
		GameLog.info(&"SmokeTest", &"results_readability_passed", directory)
	get_tree().quit(0 if failures.is_empty() else 1)


func _check_layout(screen: Control, case_name: String) -> void:
	var overview: RichTextLabel = screen.get_node("NextStep/Overview")
	_expect(overview.get_content_height() <= overview.size.y, case_name + " default overview needs scrolling")
	for card in ["Profit", "Credit", "Cash"]:
		var note: Control = screen.get_node("NextStep/" + card + "Note")
		_expect(screen.get_node("NextStep/" + card + "Card").get_global_rect().encloses(note.get_global_rect()), case_name + " note outside card: " + card)
	for name in ["NetIncome", "Credit", "Totals", "ProfitNote", "CashNote", "DetailButton", "RecoveryButton", "Notice", "SettleButton", "QuitButton"]:
		var control: Control = screen.get_node("NextStep/" + name)
		_expect(get_viewport().get_visible_rect().encloses(control.get_global_rect()), case_name + " clipped " + name + " %s / %s" % [control.get_global_rect(), get_viewport().get_visible_rect()])
		if control is Label:
			var label := control as Label
			var font := label.get_theme_font("font")
			var size := label.get_theme_font_size("font_size")
			for line in label.text.split("\n"):
				if label.clip_text:
					_expect(font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= label.size.x + 1, case_name + " truncated number " + name)
	_expect(not screen.get_node("NextStep/ProfitCard").get_global_rect().intersects(screen.get_node("NextStep/CreditCard").get_global_rect()), "Metric cards overlap")


func _capture(label: String) -> void:
	if render and DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		_expect(get_viewport().get_texture().get_image().save_png(directory.path_join(label + ".png")) == OK, "Cannot capture " + label)
		captures += 1


func _frames(count: int) -> void:
	for frame in count:
		await get_tree().process_frame


func _tap(key: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = key
		event.physical_keycode = key
		event.pressed = pressed
		get_viewport().push_input(event, true)


func _click(button: Button) -> void:
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = button.get_global_rect().get_center()
		event.pressed = pressed
		get_viewport().push_input(event, true)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
		push_error(message)
