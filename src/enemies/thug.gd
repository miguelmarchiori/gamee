class_name Thug
extends Enemy
## The knife thug: patrols his platform, chases Zack when he sees him on his
## level, warns with a "!" while winding up, then stabs. Numbers come from the
## "enemies" tuning section (thug_*).

enum State { PATROL, CHASE, WINDUP, SLASH, RECOVER }

## Current behaviour.
var state := State.PATROL

var _timer := 0.0
var _dir := -1


func _init() -> void:
	kind = "thug"


func _ready() -> void:
	super._ready()
	_dir = facing


func _think(delta: float) -> void:
	var zack := session.zack
	var dx := zack.global_position.x - global_position.x
	match state:
		State.PATROL:
			if _edge_ahead(_dir) or _wall_ahead(_dir):
				_dir = -_dir
			velocity.x = _dir * _t("thug_patrol_speed")
			facing = _dir
			if _sees(zack):
				state = State.CHASE
		State.CHASE:
			facing = 1 if dx >= 0.0 else -1
			velocity.x = 0.0 if _edge_ahead(facing) or _wall_ahead(facing) else facing * _t("thug_chase_speed")
			if not zack.alive:
				state = State.PATROL
			elif absf(dx) < _t("thug_reach") + 8.0 and absf(zack.chest().y - chest().y) < 20.0:
				state = State.WINDUP
				_timer = _t("thug_windup")
		State.WINDUP:
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				state = State.SLASH
				_timer = _t("thug_slash_time")
		State.SLASH:
			_timer -= delta
			velocity.x = facing * _t("thug_slash_step")
			if zack.alive and _blade().intersects(zack.hurtbox()):
				session.kill_player(facing)
			if _timer <= 0.0:
				state = State.RECOVER
				_timer = _t("thug_recover")
		State.RECOVER:
			velocity.x = 0.0
			_timer -= delta
			if _timer <= 0.0:
				state = State.CHASE


func pose() -> String:
	match state:
		State.WINDUP:
			return "windup"
		State.SLASH:
			return "slash"
	return "run" if absf(velocity.x) > 5.0 else "idle"


func _draw() -> void:
	super._draw()
	if not alive:
		return
	if state == State.WINDUP:  # the warning: a yellow "!" over his head
		draw_rect(Rect2(-2, -38, 4, 10), FigurePainter.OUTLINE)
		draw_rect(Rect2(-1, -37, 2, 5), Color("#ffb347"))
		draw_rect(Rect2(-1, -31, 2, 2), Color("#ffb347"))
	elif state == State.CHASE:
		draw_rect(Rect2(-1, -33, 2, 2), Color("#d2392c"))


func _sees(zack: Zack) -> bool:
	if not zack.alive:
		return false
	var d := zack.chest() - chest()
	return absf(d.x) < _t("thug_sight") and absf(d.y) < _t("thug_sight_height") and session.room.line_clear(chest(), zack.chest())


func _blade() -> Rect2:
	var reach := _t("thug_reach")
	var x := global_position.x + WIDTH / 2.0 - 2.0 if facing > 0 else global_position.x - WIDTH / 2.0 - reach + 2.0
	return Rect2(x, global_position.y - HEIGHT + 4.0, reach, 12.0)


func _edge_ahead(dir: int) -> bool:
	var probe := global_position + Vector2(dir * (WIDTH / 2.0 + 2.0), 4.0)
	return not session.room.point_solid(probe)


func _wall_ahead(dir: int) -> bool:
	var x := global_position.x + WIDTH / 2.0 if dir > 0 else global_position.x - WIDTH / 2.0 - 2.0
	return session.room.rect_hits(Rect2(x, global_position.y - HEIGHT + 2.0, 2.0, HEIGHT - 4.0))


func _t(key: String) -> float:
	return Tuning.value("enemies", key)
