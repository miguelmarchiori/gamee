extends Node2D
## The gray test room (the approved spike's room) to try every move, the combat
## and the enemies. Run with `-- --demo=move`, `-- --demo=combat` or
## `-- --demo=enemies` for the scripted evidence runs in production/qa/evidence/.

const ROOM_PATH := "res://assets/data/rooms/test_room.json"
const HELP := "A D mover · W/Espaço pular (2x no ar) · S rolar · Shift dash · clique soco · direito/E pegar/arremessar · R recomeçar"
const ITEM_NAMES := {"": "-", "bottle": "garrafa", "knife": "faca", "pistol": "pistola"}

var session: RoomSession
var _status: Label
var _demo := ""
var _frame := 0


func _ready() -> void:
	process_physics_priority = -10  # the demo presses keys before anyone reads them
	session = RoomSession.new()
	add_child(session)
	session.setup(ROOM_PATH)
	var hud := CanvasLayer.new()
	add_child(hud)
	_status = _label(hud, Vector2(6, 4))
	_label(hud, Vector2(6, 256)).text = HELP
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--demo="):
			_demo = arg.trim_prefix("--demo=")


func _physics_process(_delta: float) -> void:
	var held := session.held_kind()
	var held_text: String = ITEM_NAMES.get(held, held)
	if held == "pistol":
		held_text += " x%d" % session.held_ammo()
	_status.text = "Alvos %d/%d · Mortes %d · %.2fs · Na mão: %s%s" % [
		session.enemies_left(), session.enemies.size(), session.deaths, session.elapsed, held_text,
		" · SALA LIMPA" if session.is_cleared else ""]
	_frame += 1
	match _demo:
		"move":
			_demo_move()
		"combat":
			_demo_combat()
		"enemies":
			_demo_enemies()


func _label(parent: Node, pos: Vector2) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", 8)
	label.modulate = Color("#d8d4cc")
	parent.add_child(label)
	return label


func _enemy_near(world: Vector2) -> Enemy:
	var best: Enemy = null
	for e in session.enemies:
		if e.alive and (best == null or e.global_position.distance_to(world) < best.global_position.distance_to(world)):
			best = e
	return best


func _aim_at(world: Vector2) -> void:
	session.zack.aim_override = world


func _tap(action: String) -> void:
	Input.action_press(action)
	Input.action_release.call_deferred(action)


## Story 001: run, jump, a second jump, dash up-right, roll.
func _demo_move() -> void:
	match _frame:
		10:
			Input.action_press("move_right")
		40:
			Input.action_press("jump")
		52:
			Input.action_release("jump")
		58:
			_tap("jump")
		76:
			_aim_at(session.zack.global_position + Vector2(60.0, -50.0))
			_tap("dash")
		120:
			_tap("down")
		150:
			Input.action_release("move_right")


## Story 002: pick up the bottle and throw it at the first thug, punch the first
## gunner (it drops its pistol), shoot the second thug with it, punch a bullet
## back, then die to a bullet and watch the room restart.
func _demo_combat() -> void:
	var zack := session.zack
	match _frame:
		5:
			Input.action_press("move_right")
		14:
			Input.action_release("move_right")
		20:
			_tap("interact")  # pick up the bottle
		28:
			zack.global_position = Vector2(170, 256)  # past the crate
		32:
			_aim_at(_enemy_near(Vector2(264, 256)).chest())
			_tap("interact")  # throw it
		80:
			zack.global_position = Vector2(196, 160)  # next to the gunner on the platform
			zack.velocity = Vector2.ZERO
		90:
			_aim_at(_enemy_near(Vector2(216, 160)).chest())
			_tap("attack")
		130:
			zack.global_position = (session.items.back()["rect"] as Rect2).get_center() + Vector2(0, 3)
		135:
			_tap("interact")  # pick up the pistol
		145:
			_aim_at(_enemy_near(Vector2(376, 192)).chest())
			_tap("interact")  # shoot
		170:
			session.spawn_bullet(zack.chest() + Vector2(60, 0), Vector2(-290, 0), true)
		174:
			_aim_at(zack.chest() + Vector2(60, 0))
			_tap("attack")  # punch the bullet back
		205:
			session.spawn_bullet(zack.chest() + Vector2(60, 0), Vector2(-290, 0), true)


## Story 003: the ground thug patrols, sees Zack, warns and stabs him; after the
## restart a gunner aims with its laser, locks and shoots.
func _demo_enemies() -> void:
	var zack := session.zack
	match _frame:
		40:
			zack.global_position = Vector2(330, 256)  # in front of the ground thug
		130:
			zack.global_position = Vector2(560, 256)  # in sight of the far gunner, on the floor
