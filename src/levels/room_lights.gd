class_name RoomLights
extends Node2D
## The room's lamps: the fixture hanging from the ceiling and an additive cone of
## light under it. "fluo" is a fluorescent tube that flickers now and then,
## "sodium" the orange street-light glow, "bulb" a bare warm bulb.
##
## Usage: var l := RoomLights.new(); l.room = room; add_child(l)

const COLORS := {"fluo": Color("#dcefe4"), "sodium": Color("#ffa040"), "bulb": Color("#ffd08a")}

## The room whose "lights" list is drawn.
var room: Room

var _time := 0.0
var _fixtures: Node2D


func _ready() -> void:
	z_index = 20
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	material = glow
	_fixtures = Node2D.new()
	_fixtures.z_index = -1
	_fixtures.z_as_relative = true
	_fixtures.use_parent_material = false
	_fixtures.draw.connect(_draw_fixtures)
	add_child(_fixtures)


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	for light: Array in room.lights:
		var kind: String = light[2]
		var color: Color = COLORS.get(kind, COLORS["bulb"])
		var top: Vector2 = Vector2(light[0] * Room.TILE + Room.TILE / 2.0, light[1] * Room.TILE + 4.0)
		var strength := 0.2
		if kind == "fluo":  # flickers in short bursts
			var beat := int(_time * 9.0 + light[0] * 3)
			if _hash(beat) > 0.93:
				strength = 0.05
		var reach := 120.0 if kind != "bulb" else 80.0
		var spread := 60.0 if kind != "bulb" else 45.0
		var lit := color
		lit.a = strength
		var dark := color
		dark.a = 0.0
		draw_polygon(
			PackedVector2Array([top + Vector2(-5, 0), top + Vector2(5, 0), top + Vector2(spread, reach), top + Vector2(-spread, reach)]),
			PackedColorArray([lit, lit, dark, dark]))


func _draw_fixtures() -> void:
	for light: Array in room.lights:
		var kind: String = light[2]
		var x: float = light[0] * Room.TILE + Room.TILE / 2.0
		var y: float = light[1] * Room.TILE
		var color: Color = COLORS.get(kind, COLORS["bulb"])
		_fixtures.draw_rect(Rect2(x, y - 2, 1, 2), Color("#121115"))
		if kind == "fluo":
			_fixtures.draw_rect(Rect2(x - 9, y, 18, 4), Color("#050506"))
			_fixtures.draw_rect(Rect2(x - 8, y, 16, 3), Color("#3a3a40"))
			_fixtures.draw_rect(Rect2(x - 7, y + 3, 14, 1), color)
		else:
			_fixtures.draw_rect(Rect2(x - 2, y, 5, 4), Color("#050506"))
			_fixtures.draw_rect(Rect2(x - 1, y + 1, 3, 3), color)


static func _hash(i: float) -> float:
	var s := sin(i * 12.9898 + 78.233) * 43758.5453
	return s - floorf(s)
