extends Node2D
## Story 001's test room: the approved spike's room in gray, with Zack and the
## camera, to try every move. Run with `-- --demo` for the scripted evidence run
## (production/qa/evidence/story-001-movimento-no-godot/).

const ROOM_PATH := "res://assets/data/rooms/test_room.json"
const ZACK_SCENE := preload("res://src/player/zack.tscn")
const HELP := "A D mover · W/Espaço pular (2x no ar, na parede escala) · S rolar / cair · Shift dash para o mouse · F11 tela cheia"

var _zack: Zack
var _demo := false
var _frame := 0


func _ready() -> void:
	process_physics_priority = -10  # the demo presses keys before Zack reads them
	var room := Room.new()
	add_child(room)
	room.load_room(ROOM_PATH)
	_zack = ZACK_SCENE.instantiate()
	_zack.position = room.spawns("P")[0]
	add_child(_zack)
	var cam := GameCamera.new()
	cam.target = _zack
	cam.set_bounds(room.size_px())
	add_child(cam)
	cam.make_current()
	cam.snap()
	var hud := CanvasLayer.new()
	var label := Label.new()
	label.text = HELP
	label.position = Vector2(6, 252)
	label.add_theme_font_size_override("font_size", 8)
	label.modulate = Color("#d8d4cc")
	hud.add_child(label)
	add_child(hud)
	_demo = "--demo" in OS.get_cmdline_user_args()


func _physics_process(_delta: float) -> void:
	if _demo:
		_demo_step()


## Scripted inputs for the evidence capture: run, jump, double jump, dash up-right,
## land, roll. Frame numbers are physics frames at 60 per second.
func _demo_step() -> void:
	_frame += 1
	match _frame:
		10:
			Input.action_press("move_right")
		40:
			Input.action_press("jump")
		52:
			Input.action_release("jump")
		58:
			Input.action_press("jump")
		59:
			Input.action_release("jump")
		76:
			_zack.aim_override = _zack.global_position + Vector2(60.0, -50.0)
			Input.action_press("dash")
		77:
			Input.action_release("dash")
		120:
			Input.action_press("down")
		121:
			Input.action_release("down")
		150:
			Input.action_release("move_right")
