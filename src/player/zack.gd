class_name Zack
extends CharacterBody2D
## Zack Reddman, the player: run, jump and double jump, wall slide and wall jump,
## invulnerable roll, fast fall and the mouse-aimed dash (2 in the air); the
## mouse-aimed punch, and picking up, throwing and shooting through RoomSession.
## Movement is ported from the approved browser spike; every number is read
## live from the "player" section of assets/data/tuning.json.
##
## Usage: instance res://src/player/zack.tscn, set its position to a spawn's feet
## position, and give a GameCamera its `target`.

## Emitted when a dash starts, with its direction.
signal dashed(direction: Vector2)
## Emitted when Zack is hit and dies.
signal died

const STAND_HEIGHT := 20.0
const ROLL_HEIGHT := 10.0
const WIDTH := 10.0
const GHOST_LIFE := 0.22
const GHOST_MAX := 14
const GHOST_TINTS: Array[Color] = [Color("#d8d2c4"), Color("#8a8478")]

## Which way Zack faces: 1 right, -1 left.
var facing := 1
## True when standing on the floor this physics frame.
var grounded := true
## True while rolling (low and invulnerable).
var rolling := false
## True while sliding down a wall he pushes into.
var wall_sliding := false
## Extra jumps left in the air (refilled on the floor or a wall).
var air_jumps := 0
## Dashes left in the air (refilled on the floor or a wall).
var air_dashes := 0
## Angle from Zack's chest to the aim point, in radians.
var aim_angle := 0.0
## World point the aim follows instead of the mouse while finite. Automated
## evidence runs set it; play leaves it at Vector2.INF.
var aim_override := Vector2.INF
## False once he has been hit.
var alive := true
## Punches with a lift left in the air (refilled on the floor or a wall).
var air_attacks := 0
## The room he is in; punches, pickups and deaths go through it.
var session: RoomSession

var _coyote := 0.0
var _buffer := 0.0
var _wall_lock := 0.0
var _dash_time := 0.0
var _dash_kind := ""
var _dash_cooldown := 0.0
var _invulnerable_time := 0.0
var _flip_time := 0.0
var _roll_time := 0.0
var _no_cut := false
var _landed_time := 0.0
var _phase := 0.0
var _vy_before := 0.0
var _height := STAND_HEIGHT
var _ghosts: Array[Dictionary] = []
var _ghost_tick := 0
var _attack_time := 0.0
var _attack_cooldown := 0.0
var _aim_y := 0
var _punches: Array[Dictionary] = []

@onready var _body: CollisionShape2D = $Body


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	_body.shape = _body.shape.duplicate()
	_set_height(STAND_HEIGHT)
	_refill_air_moves()


## True while Zack cannot be hurt: rolling, or during a dash.
func is_invulnerable() -> bool:
	return rolling or _invulnerable_time > 0.0


## Zack's chest, the point aim and hits are measured from.
func chest() -> Vector2:
	return global_position + Vector2(0.0, -_height / 2.0)


## The rectangle enemy hits have to touch, in world pixels.
func hurtbox() -> Rect2:
	return Rect2(global_position.x - WIDTH / 2.0, global_position.y - _height, WIDTH, _height)


## One hit kills him: he is thrown toward `dir_x` and stops taking input.
## Called by RoomSession.kill_player.
func die(dir_x: float) -> void:
	if not alive:
		return
	alive = false
	if rolling:
		_end_roll()
	_attack_time = 0.0
	_punches.clear()
	velocity = Vector2(dir_x * 160.0, -150.0)
	died.emit()


func _physics_process(delta: float) -> void:
	if session and session.frozen():
		return
	if not alive:
		velocity.y += 900.0 * delta
		if is_on_floor():
			velocity.x *= 0.6
		move_and_slide()
		queue_redraw()
		return
	var dir := int(signf(Input.get_axis("move_left", "move_right")))
	var jump_hit := Input.is_action_just_pressed("jump")
	var jump_held := Input.is_action_pressed("jump")
	var down_hit := Input.is_action_just_pressed("down")
	var jump_height := _t("jump_height")
	var apex := _t("jump_apex_time")
	var gravity := 2.0 * jump_height / (apex * apex)
	var jump_speed := 2.0 * jump_height / apex

	var was_grounded := grounded
	grounded = is_on_floor()
	if grounded:
		_coyote = _t("coyote_time")
		_refill_air_moves()
	else:
		_coyote -= delta
	if grounded and not was_grounded and _vy_before > 200.0:
		_landed_time = 0.1
	_buffer = _t("jump_buffer") if jump_hit else _buffer - delta
	_wall_lock -= delta
	_attack_cooldown -= delta
	_dash_cooldown -= delta
	_invulnerable_time -= delta
	_flip_time -= delta
	_landed_time -= delta
	var was_dashing := _dash_time > 0.0
	_dash_time -= delta
	if was_dashing and _dash_time <= 0.0 and _dash_kind == "dash":
		var keep := _t("dash_end_keep")
		velocity.x *= keep
		if velocity.y < 0.0:
			velocity.y *= keep
		_dash_kind = ""
	var wall_left := not grounded and test_move(global_transform, Vector2(-2.0, 0.0))
	var wall_right := not grounded and test_move(global_transform, Vector2(2.0, 0.0))
	aim_angle = (_aim_point() - chest()).angle()

	# Roll on the floor, fast fall in the air.
	if down_hit and grounded and not rolling:
		var d := dir if dir != 0 else facing
		rolling = true
		_roll_time = _t("roll_time")
		_set_height(ROLL_HEIGHT)
		velocity.x = d * maxf(absf(velocity.x), _t("roll_speed"))
		facing = d
	elif down_hit and not grounded and not rolling and _dash_time <= 0.0:
		velocity.y = maxf(velocity.y, _t("max_fall_speed") * 0.85)
		_no_cut = false
	if rolling:
		_roll_time -= delta
		velocity.x = move_toward(velocity.x, 0.0, _t("roll_friction") * delta)
		if (_roll_time <= 0.0 or not grounded) and _can_stand():
			_end_roll()

	# Running: the momentum of a dash or a wall jump carries in the air.
	if not rolling and _wall_lock <= 0.0 and _dash_time <= 0.0:
		var run := _t("run_speed")
		var accel: float
		if dir != 0 and absf(velocity.x) > run and int(signf(velocity.x)) == dir:
			accel = _t("ground_friction") * 0.5 if grounded else 120.0
		elif dir != 0:
			accel = _t("ground_accel") if grounded else _t("air_accel")
		else:
			accel = _t("ground_friction") if grounded else _t("air_drag")
		velocity.x = move_toward(velocity.x, dir * run, accel * delta)
		if dir != 0 and _attack_time <= 0.0:
			facing = dir

	# Jump, wall jump, double jump.
	if _buffer > 0.0 and (grounded or _coyote > 0.0) and (not rolling or _can_stand()):
		if rolling:
			_end_roll()
		velocity.y = -jump_speed
		_buffer = 0.0
		_coyote = 0.0
		grounded = false
	elif _buffer > 0.0 and not grounded and (wall_left or wall_right) and not rolling:
		var away := 1 if wall_left else -1
		velocity.y = -jump_speed * _t("wall_jump_up")
		velocity.x = away * _t("wall_jump_push")
		facing = away
		_wall_lock = _t("wall_jump_lock")
		_buffer = 0.0
		_refill_air_moves()
		_no_cut = true
	elif jump_hit and not grounded and air_jumps > 0 and not rolling:
		velocity.y = -jump_speed * _t("double_jump_mult")
		air_jumps -= 1
		_buffer = 0.0
		_flip_time = _t("flip_time")
		_dash_time = 0.0
		_dash_kind = ""
		if dir != 0:
			velocity.x = dir * maxf(absf(velocity.x), _t("run_speed") * 0.8)
			facing = dir

	# Gravity: falls faster than it rises; letting go of jump early cuts the jump.
	var g := gravity
	if velocity.y >= 0.0:
		_no_cut = false
	if _dash_time > 0.0:
		g = 0.0
	elif velocity.y > 0.0:
		g *= _t("fall_gravity_mult")
	elif not jump_held and not _no_cut:
		g *= _t("jump_cut_gravity_mult")
	velocity.y = minf(velocity.y + g * delta, _t("max_fall_speed"))

	wall_sliding = not grounded and velocity.y > 0.0 and ((wall_left and dir < 0) or (wall_right and dir > 0))
	if wall_sliding:
		velocity.y = minf(velocity.y, _t("wall_slide_speed"))
		facing = 1 if wall_left else -1
		_refill_air_moves()

	# Dash toward the aim: invulnerable, 2 in the air.
	if Input.is_action_just_pressed("dash") and _dash_cooldown <= 0.0 and (grounded or air_dashes > 0) and (not rolling or _can_stand()):
		if rolling:
			_end_roll()
		var ang := aim_angle
		if grounded and sin(ang) > 0.2:  # on the floor, a dash aimed down goes sideways
			ang = 0.0 if cos(ang) >= 0.0 else PI
		if not grounded:
			air_dashes -= 1
		var direction := Vector2.from_angle(ang)
		velocity = direction * _t("dash_speed")
		_dash_time = _t("dash_duration")
		_dash_kind = "dash"
		_invulnerable_time = _dash_time + 0.04
		_dash_cooldown = _t("dash_cooldown")
		_no_cut = true
		if absf(direction.x) > 0.2:
			facing = 1 if direction.x > 0.0 else -1
		dashed.emit(direction)

	_punch(delta)
	if Input.is_action_just_pressed("interact") and session:
		session.interact(Vector2.from_angle(aim_angle))

	_vy_before = velocity.y
	move_and_slide()
	_phase += absf(velocity.x) * delta * 0.09
	_update_ghosts(delta)
	queue_redraw()


## The mouse-aimed punch: a short step, one lift in the air, and a hit window
## in which RoomSession kills what the fist touches and sends bullets back.
func _punch(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and _attack_cooldown <= 0.0 and (not rolling or _can_stand()):
		if rolling:
			_end_roll()
		var direction := Vector2.from_angle(aim_angle)
		_attack_time = _c("attack_time")
		_attack_cooldown = _c("attack_cooldown")
		facing = 1 if direction.x >= 0.0 else -1
		_aim_y = -1 if direction.y < -0.55 else (1 if direction.y > 0.55 else 0)
		var step := _c("attack_dash")
		var lift := grounded or air_attacks > 0
		if not grounded and lift:
			air_attacks -= 1
		if lift:
			velocity.x = direction.x * step
			if not (grounded and direction.y > 0.0):
				velocity.y = direction.y * step
			_dash_time = _c("attack_dash_time")
			_no_cut = true
		else:  # no lift left: a short punch that only holds the fall for a moment
			velocity.x = direction.x * step * 0.45
			velocity.y = minf(velocity.y, 60.0)
			_dash_time = 0.04
		_dash_kind = "attack"
		_punches.append({"angle": aim_angle, "t": 0.16})
	if _attack_time > 0.0:
		_attack_time -= delta
		if _attack_time < 0.18 and _attack_time > 0.05 and session:
			var reach := _c("attack_reach")
			var dir := Vector2.from_angle(_punches.back()["angle"] if not _punches.is_empty() else aim_angle)
			session.punch(chest() + dir * reach * 0.7, reach * 0.8, dir)
	for p in _punches:
		p["t"] = float(p["t"]) - delta
	while not _punches.is_empty() and float(_punches[0]["t"]) <= 0.0:
		_punches.pop_front()


func _draw() -> void:
	for ghost in _ghosts:
		var state: Dictionary = ghost["state"]
		state["tint"] = ghost["tint"]
		state["alpha"] = 0.45 * float(ghost["life"]) / GHOST_LIFE
		FigurePainter.paint(self, ghost["pos"] - global_position, ghost["facing"], ghost["pose"], "zack", state)
	if not alive:
		FigurePainter.paint(self, Vector2.ZERO, facing, "dead", "zack", {})
		return
	FigurePainter.paint(self, Vector2.ZERO, facing, _pose(), "zack", _paint_state())
	_draw_punches()


## The punching arm: it shoots out toward the aim and pulls back, with speed
## lines behind the fist and a small ring when it lands.
func _draw_punches() -> void:
	var reach := _c("attack_reach")
	for p in _punches:
		var k := 1.0 - float(p["t"]) / 0.16
		var ext := k / 0.35 if k < 0.35 else 1.0 - (k - 0.35) / 0.65 * 0.7
		var dir := Vector2.from_angle(p["angle"])
		var shoulder := Vector2(1.0 if dir.x >= 0.0 else -1.0, -_height + minf(6.0, _height / 2.0) + 1.0)
		var length := 3.0 + ext * reach
		var fist := shoulder + dir * length
		if k < 0.5:
			var line := Color(1, 1, 1, 0.7 * (1.0 - k * 2.0))
			for o: float in [-3.0, 0.0, 3.0]:
				for i in range(5, 13):
					var q := fist - dir * i * 1.5 + Vector2(-dir.y, dir.x) * o
					draw_rect(Rect2(q.round(), Vector2.ONE), line)
		for i in int(length) + 1:
			draw_rect(Rect2((shoulder + dir * i).round() - Vector2(2, 2), Vector2(5, 5)), FigurePainter.OUTLINE)
		for i in int(length) + 1:
			draw_rect(Rect2((shoulder + dir * i).round() - Vector2.ONE, Vector2(3, 3)), FigurePainter.ZACK["coat"])
		var f := fist.round()
		draw_rect(Rect2(f - Vector2(3, 3), Vector2(7, 7)), FigurePainter.OUTLINE)
		draw_rect(Rect2(f - Vector2(2, 2), Vector2(5, 5)), FigurePainter.ZACK["glove"])
		draw_rect(Rect2(f + Vector2(1.0 if dir.x >= 0.0 else -2.0, -2.0), Vector2(2, 5)), Color("#9a7a8c"))
		if k > 0.3 and k < 0.6:
			draw_arc(fist + dir * 4.0, 2.0 + (k - 0.3) * 30.0, 0.0, TAU, 16, Color(1.0, 0.94, 0.78, 1.0 - (k - 0.3) / 0.3), 1.0)


func _pose() -> String:
	if rolling or (_flip_time > 0.0 and not grounded):
		return "roll"
	if _attack_time > 0.04:
		return "attack"
	if wall_sliding:
		return "wall"
	if not grounded:
		return "air"
	return "run" if absf(velocity.x) > 20.0 else "idle"


func _paint_state() -> Dictionary:
	var progress := 0.0
	if rolling:
		progress = 1.0 - maxf(0.0, _roll_time) / _t("roll_time")
	elif _flip_time > 0.0:
		progress = 1.0 - _flip_time / _t("flip_time")
	return {
		"phase": _phase,
		"vx": velocity.x,
		"landed": _landed_time,
		"roll_progress": progress,
		"flip": _flip_time > 0.0 and not rolling,
		"live_fist": true,
		"aim_y": _aim_y,
	}


func _update_ghosts(delta: float) -> void:
	for ghost in _ghosts:
		ghost["life"] = float(ghost["life"]) - delta
	while not _ghosts.is_empty() and float(_ghosts[0]["life"]) <= 0.0:
		_ghosts.pop_front()
	_ghost_tick += 1
	var fast := _dash_time > 0.0 or rolling or _wall_lock > 0.0 or absf(velocity.x) > _t("run_speed") * 1.15
	if fast and (_ghost_tick % 2 == 0 or _invulnerable_time > 0.0):
		_ghosts.append({
			"pos": global_position, "facing": facing, "pose": _pose(), "state": _paint_state(),
			"life": GHOST_LIFE, "tint": GHOST_TINTS[_ghost_tick % 2],
		})
		if _ghosts.size() > GHOST_MAX:
			_ghosts.pop_front()


func _aim_point() -> Vector2:
	return aim_override if aim_override.is_finite() else get_global_mouse_position()


func _refill_air_moves() -> void:
	air_jumps = int(_t("air_jumps"))
	air_dashes = int(_t("air_dashes"))
	air_attacks = int(_c("air_attacks"))


func _can_stand() -> bool:
	return not rolling or not test_move(global_transform, Vector2(0.0, -(STAND_HEIGHT - ROLL_HEIGHT)))


func _end_roll() -> void:
	rolling = false
	_set_height(STAND_HEIGHT)


func _set_height(h: float) -> void:
	_height = h
	(_body.shape as RectangleShape2D).size = Vector2(WIDTH, h)
	_body.position = Vector2(0.0, -h / 2.0)


func _t(key: String) -> float:
	return Tuning.value("player", key)


func _c(key: String) -> float:
	return Tuning.value("combat", key)
