class_name Effects
extends Node2D
## Blood, sparks and impact rings, drawn above the characters. Blood that hits a
## wall stays there as a stain until the room restarts.
##
## Usage: effects.gore(position, direction_x, 28); effects.ring(position, color)

const GRAVITY := 600.0
const MAX_STAINS := 700
const BLOOD := Color("#c8202c")
const BLOOD_DARK := Color("#7a0e18")

## The room the blood collides with.
var room: Room

var _parts: Array[Dictionary] = []
var _stains: Array[Dictionary] = []
var _rings: Array[Dictionary] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	z_index = 5
	_rng.seed = 1


## Removes every particle, ring and stain (room restart).
func clear() -> void:
	_parts.clear()
	_stains.clear()
	_rings.clear()
	queue_redraw()


## A spray of blood from `pos`, thrown toward `dir_x` (-1 or 1).
func gore(pos: Vector2, dir_x: float, count: int) -> void:
	for i in count:
		_parts.append({
			"pos": pos,
			"vel": Vector2(dir_x * _rng.randf_range(40.0, 260.0) + _rng.randf_range(-60.0, 60.0), _rng.randf_range(-280.0, -60.0)),
			"life": _rng.randf_range(0.6, 1.4), "color": BLOOD if _rng.randf() < 0.6 else BLOOD_DARK,
			"size": 2.0 if _rng.randf() < 0.35 else 1.0, "stick": true,
		})


## A few short-lived sparks at `pos`.
func sparks(pos: Vector2, color: Color, count: int) -> void:
	for i in count:
		_parts.append({
			"pos": pos, "vel": Vector2(_rng.randf_range(-110.0, 110.0), _rng.randf_range(-160.0, 0.0)),
			"life": _rng.randf_range(0.2, 0.5), "color": color, "size": 1.0, "stick": false,
		})


## An impact ring at `pos`; `flat` draws a dust ring on the floor instead.
func ring(pos: Vector2, color: Color, flat := false, duration := 0.25) -> void:
	_rings.append({"pos": pos, "color": color, "flat": flat, "t": duration, "max": duration, "rot": _rng.randf() * 3.0})


func _physics_process(delta: float) -> void:
	for p in _parts:
		p["life"] = float(p["life"]) - delta
		var vel: Vector2 = p["vel"]
		vel.y += GRAVITY * delta
		p["vel"] = vel
		var next: Vector2 = p["pos"] + vel * delta
		if p["stick"] and room and room.point_solid(next):
			p["life"] = 0.0
			if _stains.size() < MAX_STAINS:
				_stains.append({"pos": (p["pos"] as Vector2).round(), "color": p["color"], "size": p["size"]})
			continue
		p["pos"] = next
	_parts = _parts.filter(func(p: Dictionary) -> bool: return float(p["life"]) > 0.0)
	for r in _rings:
		r["t"] = float(r["t"]) - delta
	_rings = _rings.filter(func(r: Dictionary) -> bool: return float(r["t"]) > 0.0)
	queue_redraw()


func _draw() -> void:
	for s in _stains:
		draw_rect(Rect2(s["pos"], Vector2(float(s["size"]) + 1.0, s["size"])), s["color"])
	for p in _parts:
		draw_rect(Rect2((p["pos"] as Vector2).round(), Vector2(p["size"], p["size"])), p["color"])
	for r in _rings:
		var k := 1.0 - float(r["t"]) / float(r["max"])
		var c: Color = r["color"]
		c.a = 1.0 - k
		var pos: Vector2 = r["pos"]
		if r["flat"]:
			var w := 3.0 + k * 14.0
			draw_rect(Rect2(pos.x - w, pos.y - 1.0, w * 2.0, 2.0), c)
			continue
		draw_arc(pos, 3.0 + k * 16.0, 0.0, TAU, 20, c, 2.0)
		var white := Color(1, 1, 1, 1.0 - k)
		for i in 6:
			var a := i * PI / 3.0 + float(r["rot"])
			draw_rect(Rect2(pos + Vector2.from_angle(a) * (6.0 + k * 14.0) - Vector2.ONE, Vector2(2, 2)), white)
