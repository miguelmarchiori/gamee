class_name Gunner
extends Enemy
## The gunner: when he sees Zack he aims with a red laser, the aim locks for the
## last moment, then he fires at the locked point and waits before aiming again.
## Losing sight before the lock cancels the aim. Numbers: "enemies" tuning (gunner_*).

enum State { IDLE, AIM }

const LASER := Color(0.85, 0.16, 0.2)

## Current behaviour.
var state := State.IDLE
## Where the shot will go, in world pixels.
var target := Vector2.ZERO

var _timer := 0.0
var _cooldown := 0.0
var _lost := 0.0


func _init() -> void:
	kind = "gunner"


## The muzzle, in world pixels.
func muzzle() -> Vector2:
	return global_position + Vector2(facing * 14.0, -16.0)


## True during the last part of the aim, when the shot can no longer move.
func is_locked() -> bool:
	return state == State.AIM and _timer <= _t("gunner_lock_time")


func _think(delta: float) -> void:
	velocity.x = 0.0
	_cooldown -= delta
	var zack := session.zack
	var sees := _sees(zack)
	match state:
		State.IDLE:
			if sees and _cooldown <= 0.0:
				state = State.AIM
				_timer = _t("gunner_aim_time")
				_lost = 0.0
				_face(zack)
				target = zack.chest()
		State.AIM:
			_timer -= delta
			if not is_locked():
				_face(zack)
				target = zack.chest()
				if sees:
					_lost = 0.0
				else:
					_lost += delta
					if _lost > _t("gunner_lose_sight"):
						state = State.IDLE
						return
			if _timer <= 0.0:
				var from := muzzle()
				session.spawn_bullet(from, from.direction_to(target) * _t("enemy_bullet_speed"), true)
				session.effects.sparks(from, Color("#ffb347"), 4)
				state = State.IDLE
				_cooldown = _t("gunner_cooldown")


func pose() -> String:
	return "aim" if state == State.AIM else "idle"


func _draw() -> void:
	if alive and state == State.AIM:
		var color := LASER
		color.a = 1.0 if is_locked() else (0.35 + 0.25 * float(Engine.get_physics_frames() / 3 % 2))
		draw_line(muzzle() - global_position, target - global_position, color, 2.0 if is_locked() else 1.0)
	super._draw()


func _face(zack: Zack) -> void:
	facing = 1 if zack.global_position.x >= global_position.x else -1


func _sees(zack: Zack) -> bool:
	return zack.alive and chest().distance_to(zack.chest()) < _t("gunner_sight") and session.room.line_clear(chest(), zack.chest())


func _t(key: String) -> float:
	return Tuning.value("enemies", key)
