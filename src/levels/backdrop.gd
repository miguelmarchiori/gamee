class_name Backdrop
extends Node2D
## Draws what sits behind a themed room: the back wall, windows onto the city at
## night (garoa, lit windows, the orange glow of the street lights), steel shop
## shutters, painted signs, boxes, a desk, the Construtora Vértice document boxes,
## sagging wires and pichação. No neon (design/narrative/historia.md).
##
## Usage: var b := Backdrop.new(); b.room = room; add it before the room node.

const WALL := Color("#1d1c21")
const WALL_LOW := Color("#16151a")
const PANEL := Color("#232228")
const WIRE := Color("#0d0d10")
const PIXO := Color("#0a0a0c")
const FRAME := Color("#2c2a2e")
const SKY_TOP := Color("#0c0e13")
const SKY_LOW := Color("#3a2818")
const BUILDING := Color("#17181d")
const LIT_WARM := Color("#e0a860")
const LIT_FLUO := Color("#dcefe4")
const RAIN := Color(0.75, 0.76, 0.8, 0.28)
const SHUTTER := Color("#2a2a30")
const SHUTTER_RIB := Color("#34343b")
const BOX := Color("#6b5236")
const BOX_DARK := Color("#4a3824")
const PAPER := Color("#d8d2c4")
const VERTICE := Color("#c8c2b4")

## The room this backdrop belongs to.
var room: Room

var _time := 0.0


func _ready() -> void:
	z_index = -10


func _process(delta: float) -> void:
	_time += delta
	if not room.windows.is_empty():
		queue_redraw()


func _draw() -> void:
	var size := room.size_px()
	draw_rect(Rect2(Vector2.ZERO, size), WALL)
	for x in range(0, int(size.x), 64):
		draw_rect(Rect2(x, 0, 1, size.y), PANEL)
	draw_rect(Rect2(0, size.y - 3 * Room.TILE, size.x, 2 * Room.TILE), WALL_LOW)
	for w: Array in room.windows:
		_window(_cells(w[0], w[1], w[2], w[3]))
	_wires(size)
	_pichacao(size)
	for p: Dictionary in room.props:
		var r := _cells(p["col"], p["row"], p["w"], p.get("h", 1))
		match p["kind"]:
			"shutter":
				_shutter(r)
			"sign":
				_sign(r, p.get("text", ""))
			"boxes":
				_boxes(r, false)
			"vertice_boxes":
				_boxes(r, true)
			"shelf_goods":
				_goods(r)
			"desk":
				_desk(r)


func _cells(col: float, row: float, w: float, h: float) -> Rect2:
	return Rect2(col * Room.TILE, row * Room.TILE, w * Room.TILE, h * Room.TILE)


func _window(r: Rect2) -> void:
	draw_rect(r.grow(2), FRAME)
	var steps := int(r.size.y / 4.0)
	for i in steps:  # night sky, orange near the ground from the street lights
		draw_rect(Rect2(r.position.x, r.position.y + i * 4.0, r.size.x, 4.0), SKY_TOP.lerp(SKY_LOW, float(i) / steps))
	var x := r.position.x
	var i := 0
	while x < r.end.x:  # far buildings with lit windows and water tanks
		var w := 10.0 + floorf(_hash(i * 7 + int(r.position.x)) * 16.0)
		var h := r.size.y * (0.35 + _hash(i * 13 + int(r.position.y)) * 0.5)
		var top := r.end.y - h
		var bw := minf(w, r.end.x - x)
		draw_rect(Rect2(x, top, bw, h), BUILDING)
		if _hash(i * 5) > 0.5 and bw > 8.0:
			draw_rect(Rect2(x + 2, top - 3, 5, 3), BUILDING)
		for wy in range(int(top) + 3, int(r.end.y) - 2, 4):
			for wx in range(int(x) + 2, int(x + bw) - 2, 3):
				var hv := _hash(wx * 3 + wy * 7)
				if hv > 0.88:
					draw_rect(Rect2(wx, wy, 1, 1), LIT_FLUO if hv > 0.96 else LIT_WARM)
		if h > r.size.y * 0.75 and int(_time * 1.2 + i) % 2 == 0:
			draw_rect(Rect2(x + bw - 2, top - 1, 1, 1), Color("#ff3b2f"))  # aviation light
		x += w + 1.0
		i += 1
	for k in 14:  # garoa
		var rx := r.position.x + fmod(_hash(k * 3.1) * r.size.x + _time * 20.0, r.size.x)
		var ry := r.position.y + fmod(_hash(k * 7.7) * r.size.y + _time * (140.0 + _hash(k) * 60.0), r.size.y - 4.0)
		draw_rect(Rect2(rx, ry, 1, 3), RAIN)
	draw_rect(Rect2(r.position.x + r.size.x / 2.0, r.position.y, 1, r.size.y), FRAME)
	draw_rect(Rect2(r.position.x, r.position.y + r.size.y / 2.0, r.size.x, 1), FRAME)


func _shutter(r: Rect2) -> void:
	draw_rect(r, SHUTTER)
	for y in range(int(r.position.y) + 2, int(r.end.y), 3):
		draw_rect(Rect2(r.position.x, y, r.size.x, 1), SHUTTER_RIB)
	draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 2), Color("#3d3d45"))
	draw_rect(Rect2(r.get_center().x - 4, r.end.y - 4, 8, 1), Color("#4a4a52"))
	_pixo_tag(r.position + Vector2(4, r.size.y * 0.35), int(r.size.x / 6.0), int(r.position.x), 10)


func _sign(r: Rect2, text: String) -> void:  # painted plate, not neon
	var plate := Rect2(r.position + Vector2(0, 3), Vector2(r.size.x, 10))
	draw_rect(plate.grow(1), Color("#121114"))
	draw_rect(plate, Color("#cfc4a8"))
	draw_rect(Rect2(plate.position, Vector2(plate.size.x, 1)), Color("#e4dac0"))
	draw_string(ThemeDB.fallback_font, plate.position + Vector2(3, 8), text, HORIZONTAL_ALIGNMENT_LEFT, plate.size.x - 6, 7, Color("#7a1e1e"))


func _boxes(r: Rect2, vertice: bool) -> void:
	var w := 14.0
	var x := r.position.x
	var row := 0
	var y := r.end.y
	while y - 11.0 >= r.position.y:
		x = r.position.x + (row % 2) * 4.0
		while x + w <= r.end.x:
			var box := Rect2(x, y - 11.0, w, 11.0)
			draw_rect(box.grow(1), Color("#0c0b0e"))
			draw_rect(box, BOX)
			draw_rect(Rect2(box.position.x, box.position.y, box.size.x, 2), BOX_DARK)
			if vertice:  # the clue: Construtora Vértice document boxes
				var c := box.get_center() + Vector2(0, 1)
				draw_colored_polygon(PackedVector2Array([c + Vector2(-4, -3), c + Vector2(4, -3), c + Vector2(0, 3)]), VERTICE)
				draw_colored_polygon(PackedVector2Array([c + Vector2(-2, -3), c + Vector2(2, -3), c + Vector2(0, 0)]), BOX)
			x += w + 1.0
		y -= 12.0
		row += 1
	if vertice:  # stencilled name above the stack
		draw_string(ThemeDB.fallback_font, Vector2(r.position.x + 1, y - 1.0), "VÉRTICE", HORIZONTAL_ALIGNMENT_LEFT, r.size.x, 6, VERTICE)


func _goods(r: Rect2) -> void:  # radios, TVs and boxes on a shelf
	var x := r.position.x + 1.0
	var k := 0
	while x < r.end.x - 6.0:
		var w := 6.0 + floorf(_hash(k * 11 + int(r.position.x)) * 6.0)
		var h := 5.0 + floorf(_hash(k * 5 + int(r.position.y)) * (r.size.y - 6.0))
		var item := Rect2(x, r.end.y - h, w, h)
		draw_rect(item.grow(1), Color("#0c0b0e"))
		draw_rect(item, Color("#3a3a42") if k % 3 else Color("#5a4a3a"))
		draw_rect(Rect2(item.position + Vector2(1, 1), Vector2(w - 2, 2)), Color("#24242a"))
		x += w + 2.0
		k += 1


func _desk(r: Rect2) -> void:
	var top := Rect2(r.position.x, r.position.y + 4, r.size.x, 3)
	draw_rect(top.grow(1), Color("#0c0b0e"))
	draw_rect(top, Color("#4a3424"))
	draw_rect(Rect2(r.position.x + 2, top.end.y, 2, r.end.y - top.end.y), Color("#2e2018"))
	draw_rect(Rect2(r.end.x - 4, top.end.y, 2, r.end.y - top.end.y), Color("#2e2018"))
	draw_rect(Rect2(r.position.x + 8, top.position.y - 2, 10, 2), PAPER)  # papers
	draw_rect(Rect2(r.position.x + 12, top.position.y - 3, 6, 1), PAPER)
	draw_rect(Rect2(r.end.x - 14, top.position.y - 8, 2, 8), Color("#2a2a30"))  # desk lamp
	draw_rect(Rect2(r.end.x - 17, top.position.y - 10, 7, 3), Color("#3a3a40"))


func _wires(size: Vector2) -> void:
	var ceiling := _ceiling_y()
	for k in 3:
		var points := PackedVector2Array()
		var y0 := ceiling + 2.0 + k * 3.0
		var sag := 6.0 + k * 3.0
		var span := 90.0 + k * 35.0
		var x := -fmod(k * 37.0, span)
		while x < size.x:
			for j in 11:
				var t := j / 10.0
				points.append(Vector2(x + t * span, y0 + sag * 4.0 * t * (1.0 - t)))
			x += span
		draw_polyline(points, WIRE, 1.0)


func _pichacao(size: Vector2) -> void:
	var count := int(size.x / 90.0)
	var ceiling := _ceiling_y()
	for k in count:
		var x := 12.0 + _hash(k * 17 + room.cols) * (size.x - 80.0)
		var band := ceiling + 18.0 + floorf(_hash(k * 29 + room.rows) * 3.0) * 26.0
		if band < size.y - 3 * Room.TILE:
			_pixo_tag(Vector2(x, band), 4 + int(_hash(k * 3) * 6.0), k * 31 + room.cols, 9)


## São Paulo pichação: tall, straight, pointed letters.
func _pixo_tag(at: Vector2, letters: int, seed: int, h: int) -> void:
	var x := roundf(at.x)
	var y := roundf(at.y)
	for i in letters:
		var a := _hash(seed + i * 7.1)
		var b := _hash(seed + i * 3.3)
		draw_rect(Rect2(x, y, 1, h), PIXO)
		if a > 0.3:
			draw_rect(Rect2(x, y, 3, 1), PIXO)
		if b > 0.45:
			draw_rect(Rect2(x + 2, y, 1, roundf(h * (0.4 + a * 0.6))), PIXO)
		if a > 0.6:
			draw_rect(Rect2(x, y + h - 1, 3, 1), PIXO)
		if b < 0.35:
			draw_rect(Rect2(x + 1, y + roundf(h / 2.0), 2, 1), PIXO)
		if a > 0.85:
			draw_rect(Rect2(x + 1, y - 2, 1, 2), PIXO)
		x += 4.0 + (1.0 if a > 0.8 else 0.0)


func _ceiling_y() -> float:
	var row := 0
	while row < room.rows - 1 and room.is_solid(int(room.cols / 2), row):
		row += 1
	return row * Room.TILE


static func _hash(i: float) -> float:
	var s := sin(i * 12.9898 + 78.233) * 43758.5453
	return s - floorf(s)
