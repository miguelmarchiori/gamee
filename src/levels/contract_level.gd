class_name ContractLevel
extends Node2D
## Plays one contract from assets/data/contracts/*.json: the Despachante's
## message on the phone, then the rooms in order. A cleared room opens its door
## and Zack walks through it to the next; dying restarts only the current room.
## Killing the target in the last room completes the contract and shows each
## room's time, the total and the deaths.
##
## Usage: put contract_level.gd on a Node2D and set `contract_path`
## (src/levels/contract_1_galeria.tscn does this for Contract 1).

## The contract is done; `result` holds id, room_times, total and deaths.
signal completed(result: Dictionary)

enum Phase { INTRO, PLAY, DONE }

## The contract file this level plays.
@export_file("*.json") var contract_path := "res://assets/data/contracts/contract_1.json"

var phase := Phase.INTRO
var contract: Dictionary = {}
var session: RoomSession
var room_index := 0
var room_times: Array[float] = []
var deaths := 0

var _hud: Hud
var _phone: PhoneMessage
var _done: CanvasLayer
var _done_frame := 0
var _demo := false
var _frame := 0


func _ready() -> void:
	process_physics_priority = -10
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(contract_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("ContractLevel: %s is not a contract file" % contract_path)
		return
	contract = parsed
	_hud = Hud.new()
	add_child(_hud)
	_hud.set_contract(contract.get("title", ""), contract.get("place", ""))
	_phone = PhoneMessage.new()
	add_child(_phone)
	_phone.dismissed.connect(_on_intro_closed)
	var msg: Dictionary = {"sender": "DESPACHANTE", "lines": contract.get("intro", [])}
	if contract.has("intro_message"):
		msg = Messages.get_message(contract["intro_message"])
	_phone.open(msg["lines"], msg["sender"])
	_demo = "--demo=contract" in OS.get_cmdline_user_args()


## Sum of the cleared rooms' times plus the current room's.
func total_time() -> float:
	var total := 0.0
	for t in room_times:
		total += t
	if session and phase == Phase.PLAY:
		total += session.elapsed
	return total


func _rooms() -> Array:
	return contract.get("rooms", [])


func _on_intro_closed() -> void:
	phase = Phase.PLAY
	_start_room(0)


func _start_room(index: int) -> void:
	if session:
		session.queue_free()
	room_index = index
	session = RoomSession.new()
	add_child(session)
	session.setup(_rooms()[index])
	session.player_died.connect(_on_player_died)
	session.cleared.connect(_on_cleared)
	session.target_killed.connect(_on_target_killed)
	_hud.message("")


func _on_player_died() -> void:
	deaths += 1
	_hud.message(tr("MORTO"), Hud.RED)


func _on_cleared() -> void:
	if room_index < _rooms().size() - 1:
		_hud.message(tr("SALA LIMPA · siga pela porta →"), Hud.AMBER)
	elif contract.get("target", "") == "":  # a contract with no marked target ends when its last room is clear
		_finish()


func _on_target_killed() -> void:
	if room_index == _rooms().size() - 1:
		_finish()


func _physics_process(_delta: float) -> void:
	if phase != Phase.PLAY or session == null:
		if phase == Phase.DONE and Engine.get_physics_frames() - _done_frame > 30:
			if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
				_continue()
		_frame += 1
		if _demo:
			_demo_step()
		return
	if session.zack.alive and session.elapsed < 0.05:  # the room just (re)started
		_hud.message("")
	var last := room_index >= _rooms().size() - 1
	if session.is_cleared and not last and session.zack.global_position.x > session.room.size_px().x - 20.0:
		room_times.append(session.elapsed)
		_start_room(room_index + 1)
		return
	_hud.update_status(room_index + 1, _rooms().size(), session.elapsed, total_time(), deaths, session.held_kind(), session.held_ammo())
	_frame += 1
	if _demo:
		_demo_step()


func _finish() -> void:
	room_times.append(session.elapsed)
	phase = Phase.DONE
	_done_frame = Engine.get_physics_frames()
	_hud.message("")
	_done = CanvasLayer.new()
	_done.layer = 40
	add_child(_done)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.03, 0.78)
	shade.size = Vector2(480, 270)
	_done.add_child(shade)
	var lines := PackedStringArray()
	for i in room_times.size():
		var room_name := tr("Sala %d") % (i + 1)
		lines.append("%s · %.2fs" % [room_name, room_times[i]])
	var total := 0.0
	for t in room_times:
		total += t
	_text(_done, tr("CONTRATO CUMPRIDO"), Vector2(0, 54), 16, Hud.TEXT)
	var outcome := tr("%s · alvo eliminado") if contract.get("target", "") != "" else tr("%s · sala limpa")
	_text(_done, outcome % contract.get("place", ""), Vector2(0, 80), 8, Hud.AMBER)
	_text(_done, "\n".join(lines), Vector2(0, 100), 8, Hud.TEXT)
	_text(_done, tr("TOTAL %.2fs · MORTES %d") % [total, deaths], Vector2(0, 100 + lines.size() * 12 + 10), 8, Hud.TEXT)
	_text(_done, tr("clique ou Enter para continuar"), Vector2(0, 228), 8, Color(Hud.TEXT, 0.6))


func _continue() -> void:
	var total := 0.0
	for t in room_times:
		total += t
	var result := {"id": contract.get("id", ""), "room_times": room_times, "total": total, "deaths": deaths}
	if completed.get_connections().is_empty():
		get_tree().reload_current_scene()  # played on its own: start the contract again
		return
	completed.emit(result)


func _text(parent: Node, text: String, pos: Vector2, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = Vector2(480, 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.modulate = color
	parent.add_child(label)


## Scripted run for the evidence capture (`-- --demo=contract`): closes the
## phone, then in each room puts Zack beside one living enemy at a time and
## punches it, and walks him through the open door.
func _demo_step() -> void:
	if phase == Phase.INTRO:
		if _frame == 40:
			_press("ui_accept")
		return
	if phase == Phase.DONE:
		return
	if _frame % 24 != 0 or not session.zack.alive:
		return
	var zack := session.zack
	if session.is_cleared:
		zack.global_position = session.room.exit_point() + Vector2(4.0, 0.0)
		zack.velocity = Vector2.ZERO
		return
	for enemy in session.enemies:
		if enemy.alive:
			var side := -1.0 if enemy.global_position.x > 40.0 else 1.0
			zack.global_position = enemy.global_position + Vector2(side * 16.0, 0.0)
			zack.velocity = Vector2.ZERO
			zack.aim_override = enemy.chest()
			_press("attack")
			return


func _press(action: String) -> void:
	Input.action_press(action)
	Input.action_release.call_deferred(action)
