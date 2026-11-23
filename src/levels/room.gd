class_name Room
extends Node2D
## A room built from a JSON grid (assets/data/rooms/*.json): '#' is solid, 'D'
## is a door that stays solid until open_doors(), a letter marks a spawn in the
## cell right above the floor it stands on. Builds the collision as merged
## rectangles and draws the concrete tiles. The file may also list "theme",
## "lights", "windows" and "props", which Backdrop and RoomLights draw.

const TILE := 16
const WALL := Color("#1b1a1e")
const TILE_FILL := Color("#141317")
const TILE_DOT := Color("#1f1e23")
const TILE_TOP := Color("#45423f")
const TILE_EDGE := Color("#8a857d")
const TILE_SHEEN := Color(0.86, 0.82, 0.75, 0.06)
const TILE_SHADE := Color("#0c0b0e")

var room_name := ""
var theme := ""
var cols := 0
var rows := 0
## Decoration from the room file, read by Backdrop and RoomLights.
var lights: Array = []
var windows: Array = []
var props: Array = []
var doors_open := false
var _grid: PackedStringArray = []
var _spawns: Dictionary = {}  # letter -> Array[Vector2] of feet positions


## Loads and builds the room. Returns false when the file is missing or malformed.
func load_room(path: String) -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("grid"):
		push_error("Room: %s is not a room file" % path)
		return false
	room_name = parsed.get("name", "")
	theme = parsed.get("theme", "")
	lights = parsed.get("lights", [])
	windows = parsed.get("windows", [])
	props = parsed.get("props", [])
	_grid = PackedStringArray(parsed["grid"])
	rows = _grid.size()
	cols = _grid[0].length()
	_read_spawns()
	_build_collision()
	queue_redraw()
	return true


## Room size in pixels.
func size_px() -> Vector2:
	return Vector2(cols * TILE, rows * TILE)


## Feet positions of every spawn marked with this letter.
func spawns(letter: String) -> Array:
	return _spawns.get(letter, [])


## True when the cell is solid; outside the grid counts as solid, and so does a
## door until the doors open.
func is_solid(col: int, row: int) -> bool:
	if col < 0 or row < 0 or row >= rows or col >= cols:
		return true
	var ch := _grid[row][col]
	return ch == "#" or (ch == "D" and not doors_open)


## Opens every door ('D'): its collision goes away and it stops being drawn.
func open_doors() -> void:
	if doors_open:
		return
	doors_open = true
	var body := get_node_or_null("Doors")
	if body:
		body.queue_free()
	queue_redraw()


## Feet position just inside the lowest door cell, or Vector2.INF when there is no door.
func exit_point() -> Vector2:
	for row in range(rows - 1, -1, -1):
		var col := _grid[row].find("D")
		if col >= 0:
			return Vector2(col * TILE + TILE / 2.0, (row + 1) * TILE)
	return Vector2.INF


## True when the room has at least one door.
func has_doors() -> bool:
	for row in rows:
		if _grid[row].contains("D"):
			return true
	return false


## True when a world point is inside a solid cell.
func point_solid(p: Vector2) -> bool:
	return is_solid(floori(p.x / TILE), floori(p.y / TILE))


## True when nothing solid stands between two world points (checked every 4 px).
func line_clear(from: Vector2, to: Vector2) -> bool:
	var steps := ceili(from.distance_to(to) / 4.0)
	for i in range(1, steps):
		if point_solid(from.lerp(to, float(i) / steps)):
			return false
	return true


## True when a world rectangle overlaps any solid cell.
func rect_hits(r: Rect2) -> bool:
	var c0 := floori(r.position.x / TILE)
	var c1 := floori((r.end.x - 0.001) / TILE)
	var r0 := floori(r.position.y / TILE)
	var r1 := floori((r.end.y - 0.001) / TILE)
	for row in range(r0, r1 + 1):
		for col in range(c0, c1 + 1):
			if is_solid(col, row):
				return true
	return false


func _read_spawns() -> void:
	_spawns.clear()
	for row in rows:
		for col in cols:
			var ch := _grid[row][col]
			if ch == "#" or ch == "." or ch == "D":
				continue
			if not _spawns.has(ch):
				_spawns[ch] = []
			_spawns[ch].append(Vector2(col * TILE + TILE / 2.0, (row + 1) * TILE))


func _build_collision() -> void:
	var doors := StaticBody2D.new()
	doors.name = "Doors"
	doors.collision_layer = 1
	doors.collision_mask = 0
	add_child(doors)
	for row in rows:
		for col in cols:
			if _grid[row][col] == "D":
				var shape := RectangleShape2D.new()
				shape.size = Vector2(TILE, TILE)
				var door_shape := CollisionShape2D.new()
				door_shape.shape = shape
				door_shape.position = Vector2(col * TILE + TILE / 2.0, row * TILE + TILE / 2.0)
				doors.add_child(door_shape)
	var body := StaticBody2D.new()
	body.name = "Solid"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	# Greedy merge: runs of solid cells per row, extended down while the run repeats.
	var open: Dictionary = {}  # "start:end" -> Rect2i in cells
	var rects: Array[Rect2i] = []
	for row in rows:
		var next_open: Dictionary = {}
		var col := 0
		while col < cols:
			if _grid[row][col] != "#":
				col += 1
				continue
			var start := col
			while col < cols and _grid[row][col] == "#":
				col += 1
			var key := "%d:%d" % [start, col]
			if open.has(key):
				var r: Rect2i = open[key]
				r.size.y += 1
				next_open[key] = r
				open.erase(key)
			else:
				next_open[key] = Rect2i(start, row, col - start, 1)
		for r: Rect2i in open.values():
			rects.append(r)
		open = next_open
	for r: Rect2i in open.values():
		rects.append(r)
	for r in rects:
		var shape := RectangleShape2D.new()
		shape.size = Vector2(r.size) * TILE
		var col_shape := CollisionShape2D.new()
		col_shape.shape = shape
		col_shape.position = Vector2(r.position) * TILE + shape.size / 2.0
		body.add_child(col_shape)


func _draw() -> void:
	if theme == "":
		draw_rect(Rect2(Vector2.ZERO, size_px()), WALL)
	for row in rows:
		for col in cols:
			if _grid[row][col] == "D" and not doors_open:
				_draw_door(col, row)
				continue
			if _grid[row][col] != "#":
				continue
			var x := col * TILE
			var y := row * TILE
			draw_rect(Rect2(x, y, TILE, TILE), TILE_FILL)
			for k in 3:
				var h := _hash(col * 17 + row * 31 + k)
				draw_rect(Rect2(x + floorf(h * 14), y + 1 + floorf(_hash(int(h * 9973)) * 14), 2, 1), TILE_DOT)
			if not is_solid(col, row - 1):
				draw_rect(Rect2(x, y, TILE, 3), TILE_TOP)
				draw_rect(Rect2(x, y, TILE, 1), TILE_EDGE)
				draw_rect(Rect2(x, y - 2, TILE, 2), TILE_SHEEN)
			if not is_solid(col - 1, row):
				draw_rect(Rect2(x, y, 1, TILE), TILE_TOP)
			if not is_solid(col + 1, row):
				draw_rect(Rect2(x + TILE - 1, y, 1, TILE), TILE_SHADE)


static func _hash(i: int) -> float:
	var s := sin(i * 12.9898 + 78.233) * 43758.5453
	return s - floorf(s)


func _draw_door(col: int, row: int) -> void:
	var x := col * TILE
	var y := row * TILE
	draw_rect(Rect2(x, y, TILE, TILE), Color("#2b2620"))
	for k in range(2, TILE, 4):
		draw_rect(Rect2(x + 1, y + k, TILE - 2, 1), Color("#3b342b"))
	draw_rect(Rect2(x, y, 1, TILE), TILE_EDGE)
