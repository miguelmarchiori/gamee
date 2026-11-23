class_name GameCamera
extends Camera2D
## Follows a target, showing more of where it faces and leaning a little toward
## the mouse; clamped to the room. Numbers come from the "camera" tuning section.
##
## Usage: var cam := GameCamera.new(); cam.target = zack; cam.set_bounds(room.size_px())

## The node to follow; it should have a `facing` property (1 or -1).
var target: Node2D

var _shake := 0.0
var _rng := RandomNumberGenerator.new()


## Shakes the view by up to `amount` pixels, fading out quickly.
func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)


## Keeps the view inside a room of this size, in pixels.
func set_bounds(size: Vector2) -> void:
	limit_left = 0
	limit_top = 0
	limit_right = int(size.x)
	limit_bottom = int(size.y)


## Jumps straight to the target, with no easing (on spawn and restart).
func snap() -> void:
	if target:
		global_position = _goal()
		reset_smoothing()


func _physics_process(delta: float) -> void:
	if target == null:
		return
	var rate := Tuning.value("camera", "follow_rate")
	global_position = global_position.lerp(_goal(), minf(1.0, delta * rate))
	_shake = maxf(0.0, _shake - delta * 20.0)
	offset = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * _shake


func _goal() -> Vector2:
	var facing: int = target.get("facing") if target.get("facing") != null else 1
	var view := get_viewport_rect().size
	var mouse_offset := (get_viewport().get_mouse_position().x - view.x / 2.0) * Tuning.value("camera", "mouse_pull")
	var x := target.global_position.x + facing * Tuning.value("camera", "lookahead") + mouse_offset
	return Vector2(x, target.global_position.y - 30.0)
