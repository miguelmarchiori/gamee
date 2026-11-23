class_name RoomSession
extends Node2D
## Runs one room: spawns Zack, the enemies and the items from the room file,
## moves bullets and thrown items, applies one-hit deaths, restarts the room
## (R at any time, or right after Zack dies) and says when the room is clear.
##
## Usage: var session := RoomSession.new(); add_child(session); session.setup("res://assets/data/rooms/test_room.json")

## Every enemy in the room is dead.
signal cleared
## Zack was hit; the room restarts after `feel.restart_delay`.
signal player_died

const ZACK_SCENE := preload("res://src/player/zack.tscn")
const ENEMY_LETTERS := {"T": "thug", "G": "gunner"}
const ITEM_LETTERS := {"b": "bottle", "k": "knife"}
const ITEM_SIZE := {"bottle": Vector2(8, 6), "knife": Vector2(8, 6), "pistol": Vector2(8, 5)}
const IMPACT := Color("#ffb347")
const GLASS := Color("#7dffb0")
const ENEMY_BULLET := Color("#ffb347")
const PLAYER_BULLET := Color("#ffffff")
const DEFLECTED := Color("#e8e2d4")
const OUTLINE := Color("#050506")

var room: Room
var zack: Zack
var effects: Effects
var camera: GameCamera
var enemies: Array[Enemy] = []
var items: Array[Dictionary] = []
var bullets: Array[Dictionary] = []
## Deaths since this session started.
var deaths := 0
## Seconds since the room (re)started, while Zack is alive and it is not clear.
var elapsed := 0.0
var is_cleared := false
## Builds an enemy for a kind ("thug", "gunner"); when unset, Thug and Gunner are used.
var enemy_factory: Callable

var _hitstop := 0.0
var _restart_in := -1.0
var _held: Dictionary = {}
var _frame := 0
var _actors: Node2D
var _layer: Node2D
var _room_path := ""


## Loads the room file and starts it. Returns false when the room could not load.
func setup(room_path: String) -> bool:
	_room_path = room_path
	process_physics_priority = -5
	room = Room.new()
	add_child(room)
	if not room.load_room(room_path):
		return false
	_actors = Node2D.new()
	add_child(_actors)
	_layer = Node2D.new()
	_layer.z_index = 3
	_layer.draw.connect(_draw_objects)
	add_child(_layer)
	effects = Effects.new()
	effects.room = room
	add_child(effects)
	camera = GameCamera.new()
	camera.set_bounds(room.size_px())
	add_child(camera)
	camera.make_current()
	restart()
	return true


## True during a hit-stop: everything in the room skips its frame.
func frozen() -> bool:
	return _hitstop > 0.0


## The item Zack holds ("bottle", "knife", "pistol") or "" when none.
func held_kind() -> String:
	return _held.get("kind", "")


## Shots left in a held pistol.
func held_ammo() -> int:
	return int(_held.get("ammo", 0))


## Enemies still alive.
func enemies_left() -> int:
	return enemies.filter(func(e: Enemy) -> bool: return e.alive).size()


## Puts Zack, every enemy and every item back where the room file has them.
func restart() -> void:
	for child in _actors.get_children():
		child.queue_free()
	enemies.clear()
	items.clear()
	bullets.clear()
	effects.clear()
	_held = {}
	is_cleared = false
	elapsed = 0.0
	_restart_in = -1.0
	_hitstop = 0.0
	zack = ZACK_SCENE.instantiate()
	zack.session = self
	zack.position = room.spawns("P")[0]
	_actors.add_child(zack)
	for letter: String in ENEMY_LETTERS:
		for feet: Vector2 in room.spawns(letter):
			var kind: String = ENEMY_LETTERS[letter]
			var enemy: Enemy
			if enemy_factory.is_valid():
				enemy = enemy_factory.call(kind)
			else:
				enemy = Thug.new() if kind == "thug" else Gunner.new()
			enemy.kind = kind
			enemy.session = self
			enemy.position = feet
			_actors.add_child(enemy)
			enemies.append(enemy)
	for letter: String in ITEM_LETTERS:
		for feet: Vector2 in room.spawns(letter):
			items.append(_new_item(ITEM_LETTERS[letter], feet))
	camera.target = zack
	camera.snap()


## A bullet from `pos` at `vel`; enemy bullets kill Zack, his kill enemies.
func spawn_bullet(pos: Vector2, vel: Vector2, from_enemy: bool) -> void:
	bullets.append({"pos": pos, "vel": vel, "enemy": from_enemy, "life": 3.0 if from_enemy else 2.0, "deflected": false})


## A punch: kills every enemy the circle touches and sends back enemy bullets in it.
func punch(center: Vector2, radius: float, direction: Vector2) -> void:
	for enemy in enemies:
		if enemy.alive and _circle_hits(center, radius, enemy.hurtbox()):
			kill_enemy(enemy, 1.0 if direction.x >= 0.0 else -1.0, direction.y)
	for b in bullets:
		if b["enemy"] and (b["pos"] as Vector2).distance_to(center) < radius * 1.3:
			var speed := (b["vel"] as Vector2).length() * _t("combat", "deflect_speed_mult")
			b["vel"] = direction * speed
			b["enemy"] = false
			b["deflected"] = true
			b["life"] = 2.0
			effects.sparks(b["pos"], IMPACT, 10)
			effects.ring(b["pos"], IMPACT, false, 0.2)
			_hitstop = maxf(_hitstop, _t("feel", "deflect_hitstop"))


## Zack's right-click: shoot a held pistol, throw what he holds, or pick up the nearest item.
func interact(direction: Vector2) -> void:
	if not _held.is_empty():
		if _held["kind"] == "pistol" and int(_held["ammo"]) > 0:
			_held["ammo"] = int(_held["ammo"]) - 1
			var muzzle := zack.chest() + direction * 8.0
			spawn_bullet(muzzle, direction * _t("combat", "player_bullet_speed"), false)
			effects.sparks(muzzle + direction * 2.0, IMPACT, 4)
			camera.shake(1.5)
			return
		var size: Vector2 = ITEM_SIZE[_held["kind"]]
		_held["mode"] = "flying"
		_held["rect"] = Rect2(zack.chest() + direction * 6.0 - size / 2.0, size)
		_held["vel"] = direction * _t("combat", "throw_speed") + Vector2(0.0, -20.0)
		_held = {}
		return
	var best: Dictionary = {}
	var best_distance := _t("combat", "pickup_radius")
	for item in items:
		if item["mode"] != "ground":
			continue
		var d := (item["rect"] as Rect2).get_center().distance_to(zack.chest())
		if d < best_distance:
			best_distance = d
			best = item
	if not best.is_empty():
		best["mode"] = "held"
		_held = best


## Kills an enemy, thrown toward `dir_x`: blood, a hit-stop and a shake. A gunner drops its pistol.
func kill_enemy(enemy: Enemy, dir_x: float, dir_y := -0.4) -> void:
	if not enemy.alive:
		return
	enemy.die(dir_x, dir_y)
	effects.gore(enemy.chest(), dir_x, 28)
	effects.ring(enemy.chest(), IMPACT)
	_hitstop = _t("feel", "hitstop")
	camera.shake(_t("feel", "shake"))
	if enemy.kind == "gunner":
		var pistol := _new_item("pistol", enemy.global_position + Vector2(0.0, -8.0), int(_t("combat", "pistol_ammo")))
		pistol["vel"] = Vector2(dir_x * 60.0, -160.0)
		items.append(pistol)
	if not is_cleared and enemies_left() == 0:
		is_cleared = true
		cleared.emit()


## Kills Zack unless he is rolling or dashing; the room restarts shortly after.
func kill_player(dir_x: float) -> void:
	if not zack.alive or is_cleared or zack.is_invulnerable():
		return
	zack.die(dir_x)
	if not _held.is_empty():
		_held["mode"] = "ground"
		_held = {}
	deaths += 1
	effects.gore(zack.chest(), dir_x, 34)
	camera.shake(_t("feel", "shake") * 1.5)
	_restart_in = _t("feel", "restart_delay")
	player_died.emit()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		restart()
		return
	if _hitstop > 0.0:
		_hitstop -= delta
		return
	_frame += 1
	if zack.alive and not is_cleared:
		elapsed += delta
	_update_items(delta)
	_update_bullets(delta)
	if _restart_in > 0.0:
		_restart_in -= delta
		if _restart_in <= 0.0:
			restart()
	_layer.queue_redraw()


func _update_items(delta: float) -> void:
	for item in items:
		var rect: Rect2 = item["rect"]
		match item["mode"]:
			"held":
				var hand := zack.global_position + Vector2(zack.facing * 6.0, -zack.STAND_HEIGHT + 9.0)
				item["rect"] = Rect2(hand - Vector2(rect.size.x / 2.0, 0.0), rect.size)
			"flying":
				var vel: Vector2 = item["vel"]
				vel.y += (60.0 if item["kind"] == "knife" else 300.0) * delta
				item["vel"] = vel
				item["spin"] = float(item["spin"]) + delta * 30.0
				var hits := _move_item(item, vel * delta)
				for enemy in enemies:
					if enemy.alive and (item["rect"] as Rect2).intersects(enemy.hurtbox()):
						kill_enemy(enemy, signf(vel.x))
						_land(item)
						break
				if item["mode"] == "flying" and (hits.x or hits.y):
					_land(item)
			"ground":
				var vel: Vector2 = item["vel"]
				vel.y += 600.0 * delta
				item["vel"] = vel
				var hits := _move_item(item, vel * delta)
				vel = item["vel"]
				if hits.y:
					vel.y = 0.0
					vel.x *= 0.5
				vel.x = move_toward(vel.x, 0.0, 200.0 * delta)
				item["vel"] = vel
	items = items.filter(func(i: Dictionary) -> bool: return i["mode"] != "gone")


func _land(item: Dictionary) -> void:
	var center := (item["rect"] as Rect2).get_center()
	if item["kind"] == "bottle":
		item["mode"] = "gone"
		effects.sparks(center, GLASS, 12)
		return
	item["mode"] = "ground"
	item["vel"] = Vector2(-(item["vel"] as Vector2).x * 0.15, -60.0)
	effects.sparks(center, DEFLECTED, 4)
	if item["kind"] == "pistol":
		item["ammo"] = 0


## Moves an item's rectangle, x then y, stopping at walls. Returns which axes hit.
func _move_item(item: Dictionary, motion: Vector2) -> Vector2i:
	var r: Rect2 = item["rect"]
	var hit := Vector2i.ZERO
	r.position.x += motion.x
	if room.rect_hits(r):
		hit.x = 1
		if motion.x > 0.0:
			r.position.x = floorf(r.end.x / Room.TILE) * Room.TILE - r.size.x - 0.01
		else:
			r.position.x = (floorf(r.position.x / Room.TILE) + 1.0) * Room.TILE + 0.01
	r.position.y += motion.y
	if room.rect_hits(r):
		hit.y = 1
		if motion.y > 0.0:
			r.position.y = floorf(r.end.y / Room.TILE) * Room.TILE - r.size.y - 0.01
		else:
			r.position.y = (floorf(r.position.y / Room.TILE) + 1.0) * Room.TILE + 0.01
	item["rect"] = r
	return hit


func _update_bullets(delta: float) -> void:
	for b in bullets:
		var pos: Vector2 = b["pos"] + b["vel"] * delta
		b["pos"] = pos
		b["life"] = float(b["life"]) - delta
		if room.point_solid(pos) or float(b["life"]) <= 0.0:
			b["life"] = 0.0
			effects.sparks(pos, IMPACT, 3)
			continue
		if b["enemy"]:
			if zack.alive and not zack.is_invulnerable() and zack.hurtbox().has_point(pos):
				b["life"] = 0.0
				kill_player(signf((b["vel"] as Vector2).x))
			continue
		for enemy in enemies:
			if enemy.alive and enemy.hurtbox().grow(1.0).has_point(pos):
				b["life"] = 0.0
				kill_enemy(enemy, signf((b["vel"] as Vector2).x))
				break
	bullets = bullets.filter(func(b: Dictionary) -> bool: return float(b["life"]) > 0.0)


func _new_item(kind: String, feet: Vector2, ammo := 0) -> Dictionary:
	var size: Vector2 = ITEM_SIZE[kind]
	return {"kind": kind, "rect": Rect2(feet - Vector2(size.x / 2.0, size.y), size), "vel": Vector2.ZERO, "mode": "ground", "ammo": ammo, "spin": 0.0}


func _t(section: String, key: String) -> float:
	return Tuning.value(section, key)


static func _circle_hits(center: Vector2, radius: float, rect: Rect2) -> bool:
	var nearest := Vector2(clampf(center.x, rect.position.x, rect.end.x), clampf(center.y, rect.position.y, rect.end.y))
	return center.distance_squared_to(nearest) < radius * radius


func _draw_objects() -> void:
	for item in items:
		if item["mode"] == "held" and not zack.alive:
			continue
		_draw_item(item)
	for b in bullets:
		var pos: Vector2 = (b["pos"] as Vector2).round()
		var color := ENEMY_BULLET if b["enemy"] else (DEFLECTED if b["deflected"] else PLAYER_BULLET)
		var tail := color
		tail.a = 0.5
		_layer.draw_line(pos, pos - (b["vel"] as Vector2) * 0.02, tail, 1.0)
		_layer.draw_rect(Rect2(pos - Vector2.ONE, Vector2(3, 3)), color)


func _draw_item(item: Dictionary) -> void:
	var p: Vector2 = (item["rect"] as Rect2).position.round()
	var spin: bool = item["mode"] == "flying" and int(item["spin"]) % 2 == 1
	match item["kind"]:
		"bottle":
			if spin:
				_layer.draw_rect(Rect2(p + Vector2(-1, 1), Vector2(9, 5)), OUTLINE)
				_layer.draw_rect(Rect2(p + Vector2(0, 2), Vector2(7, 3)), Color("#2f9e5f"))
			else:
				_layer.draw_rect(Rect2(p + Vector2(1, -1), Vector2(5, 8)), OUTLINE)
				_layer.draw_rect(Rect2(p + Vector2(2, 0), Vector2(3, 6)), Color("#2f9e5f"))
			_layer.draw_rect(Rect2(p + (Vector2(1, 3) if spin else Vector2(3, 1)), Vector2.ONE), GLASS)
		"knife":
			_layer.draw_rect(Rect2(p + Vector2(-1, 1), Vector2(11, 4)), OUTLINE)
			_layer.draw_rect(Rect2(p + Vector2(0, 3), Vector2(6, 1)), Color("#dfe6f2"))
			_layer.draw_rect(Rect2(p + Vector2(1, 2), Vector2(4, 1)), Color("#dfe6f2"))
			_layer.draw_rect(Rect2(p + Vector2(6, 2), Vector2(3, 2)), Color("#5a3a20"))
		"pistol":
			_layer.draw_rect(Rect2(p + Vector2(-1, 0), Vector2(9, 4)), OUTLINE)
			_layer.draw_rect(Rect2(p + Vector2(3, 2), Vector2(4, 5)), OUTLINE)
			_layer.draw_rect(Rect2(p + Vector2(0, 1), Vector2(7, 2)), Color("#9aa0b4"))
			_layer.draw_rect(Rect2(p + Vector2(4, 3), Vector2(2, 3)), Color("#555a6a"))
	if item["mode"] == "ground":  # blinking mark: it can be picked up
		var on := (_frame / 8) % 2 == 0
		_layer.draw_rect(Rect2(p + Vector2(3, -5), Vector2(2, 2)), IMPACT if on else Color(1.0, 0.7, 0.28, 0.4))
