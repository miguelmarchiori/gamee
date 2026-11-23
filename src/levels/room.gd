class_name Room
extends Node2D
## A room built from a JSON grid (assets/data/rooms/*.json): '#' is solid, a
## letter marks a spawn in the cell right above the floor it stands on.
## Builds the collision as merged rectangles and draws the concrete tiles.

const TILE := 16
const WALL := Color("#1b1a1e")
const TILE_FILL := Color("#141317")
const TILE_DOT := Color("#1f1e23")
const TILE_TOP := Color("#45423f")
const TILE_EDGE := Color("#8a857d")
const TILE_SHEEN := Color(0.86, 0.82, 0.75, 0.06)
const TILE_SHADE := Color("#0c0b0e")

var room_name := ""
var cols := 0
var rows := 0
var _grid: PackedStringArray = []
var _spawns: Dictionary = {}  # letter -> Array[Vector2] of feet positions


## Loads and builds the room. Returns false when the file is missing or malformed.
func load_room(path: String) -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("grid"):
		push_error("Room: %s is not a room file" % path)
		return false
	room_name = parsed.get("name", "")
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


## True when the cell is solid; outside the grid counts as solid.
func is_solid(col: int, row: int) -> bool:
	if col < 0 or row < 0 or row >= rows or col >= cols:
		return true
	return _grid[row][col] == "#"


func _read_spawns() -> void:
	_spawns.clear()
	for row in rows:
		for col in cols:
			var ch := _grid[row][col]
			if ch == "#" or ch == ".":
				continue
			if not _spawns.has(ch):
				_spawns[ch] = []
			_spawns[ch].append(Vector2(col * TILE + TILE / 2.0, (row + 1) * TILE))


func _build_collision() -> void:
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
			if not is_solid(col, row):
				col += 1
				continue
			var start := col
			while col < cols and is_solid(col, row):
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
	draw_rect(Rect2(Vector2.ZERO, size_px()), WALL)
	for row in rows:
		for col in cols:
			if not is_solid(col, row):
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
