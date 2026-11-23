extends Node
## The whole game, start to end: the title screen, then every step in
## assets/data/campaign.json in order (Contract 1 to 4, each opening with the
## Despachante's message), then the final. The title always starts from zero.
## Nothing is saved between sessions (story 005, out of scope).

const CAMPAIGN_PATH := "res://assets/data/campaign.json"

var steps: Array = []
var step_index := -1
var deaths := 0

var _title: TitleScreen
var _current: Node
var _demo := false
var _frame := 0


func _ready() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(CAMPAIGN_PATH))
	steps = parsed.get("steps", []) if typeof(parsed) == TYPE_DICTIONARY else []
	_demo = "--demo=flow" in OS.get_cmdline_user_args()
	_show_title()


func _show_title() -> void:
	_clear()
	step_index = -1
	deaths = 0
	_title = TitleScreen.new()
	add_child(_title)
	_title.started.connect(_next_step)


func _next_step() -> void:
	_clear()
	step_index += 1
	if step_index >= steps.size():
		_show_title()
		return
	var step: String = steps[step_index]
	if step == "final":
		_play_final()
		return
	var level := ContractLevel.new()
	level.contract_path = step
	add_child(level)
	level.completed.connect(_on_contract_completed)
	_current = level


func _on_contract_completed(result: Dictionary) -> void:
	deaths += int(result.get("deaths", 0))
	_next_step()


## The last step. In this thin version the Último Prédio is the Despachante's
## last message, then the ending and the epilogue (EndingScreen, story 006);
## story 008 makes the building playable.
func _play_final() -> void:
	var phone := PhoneMessage.new()
	add_child(phone)
	var msg := Messages.get_message("final_intro")
	phone.open(msg["lines"], msg["sender"])
	phone.dismissed.connect(_on_final_message_closed)
	_current = phone


func _on_final_message_closed() -> void:
	_clear()
	var ending := EndingScreen.new()
	add_child(ending)
	ending.finished.connect(_show_title)
	_current = ending


func _clear() -> void:
	for child in get_children():
		child.queue_free()
	_current = null
	_title = null


func _process(_delta: float) -> void:
	if not _demo:
		return
	_frame += 1
	# The scripted run: start from the title, and close each contract's end screen.
	if _title and _frame % 40 == 0:
		_press("ui_accept")
	elif _current is ContractLevel and (_current as ContractLevel).phase == ContractLevel.Phase.DONE and _frame % 40 == 0:
		_press("ui_accept")
	elif _current is PhoneMessage and (_current as PhoneMessage).is_open and _frame % 40 == 0:
		_press("ui_accept")
	elif _current is EndingScreen and _frame % 360 == 0:
		_press("ui_accept")


func _press(action: String) -> void:
	Input.action_press(action)
	Input.action_release.call_deferred(action)
