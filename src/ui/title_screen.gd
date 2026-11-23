class_name TitleScreen
extends CanvasLayer
## The title screen: São Paulo at night through the rain, Zack in the street
## light, the provisional title and "clique ou Enter para começar".
##
## Usage: var title := TitleScreen.new(); add_child(title); title.started.connect(_start)

## The player asked to start from the first contract.
signal started

const SKY_TOP := Color("#0c0e13")
const SKY_LOW := Color("#3a2818")
const BUILDING := Color("#17181d")
const NEAR := Color("#1f2026")
const LIT := Color("#e0a860")
const TEXT := Color("#d8d4cc")
const RED := Color("#d2392c")

var _root: Control
var _time := 0.0
var _opened_frame := 0


func _ready() -> void:
	layer = 30
	_root = Control.new()
	_root.size = Vector2(480, 270)
	_root.draw.connect(_draw_scene)
	add_child(_root)
	_label("ZACK REDDMAN", Vector2(0, 46), 24, TEXT)
	_label(tr("título provisório"), Vector2(0, 76), 7, Color(TEXT, 0.5))
	_label(tr("São Paulo, 2026"), Vector2(0, 90), 8, RED)
	_label(tr("clique ou Enter para começar"), Vector2(0, 236), 8, TEXT)
	_opened_frame = Engine.get_process_frames()


func _process(delta: float) -> void:
	_time += delta
	_root.queue_redraw()
	if Engine.get_process_frames() - _opened_frame < 10:
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		started.emit()


func _draw_scene() -> void:
	for i in 34:  # sky, orange near the ground from the street lights
		_root.draw_rect(Rect2(0, i * 8, 480, 8), SKY_TOP.lerp(SKY_LOW, i / 34.0))
	_skyline(BUILDING, 100, 60, 0)
	_skyline(NEAR, 55, 45, 99)
	_root.draw_rect(Rect2(0, 226, 480, 44), Color("#121115"))
	_root.draw_rect(Rect2(0, 226, 480, 1), Color("#45423f"))
	var post := Vector2(330, 226)  # street light and Zack under it
	_root.draw_rect(Rect2(post.x, 120, 3, 106), Color("#2a2a30"))
	_root.draw_rect(Rect2(post.x - 14, 118, 17, 4), Color("#2a2a30"))
	_root.draw_rect(Rect2(post.x - 14, 122, 8, 2), Color("#ffa040"))
	var glow := Color("#ffa040")
	glow.a = 0.12
	_root.draw_colored_polygon(PackedVector2Array([Vector2(post.x - 16, 124), Vector2(post.x - 4, 124), Vector2(post.x + 30, 226), Vector2(post.x - 50, 226)]), glow)
	FigurePainter.paint(_root, Vector2(post.x - 10, 226), -1, "idle", "zack", {})
	for k in 70:  # garoa
		var x := fmod(_hash(k * 3.1) * 520.0 - _time * 25.0 + 520.0, 520.0) - 20.0
		var y := fmod(_hash(k * 7.7) * 270.0 + _time * (150.0 + _hash(k) * 70.0), 270.0)
		_root.draw_rect(Rect2(x, y, 1, 4), Color(0.75, 0.76, 0.8, 0.25))


func _skyline(color: Color, base_height: float, spread: float, seed: int) -> void:
	var x := -10.0
	var i := 0
	while x < 480.0:
		var w := 22.0 + floorf(_hash(i * 7 + seed) * 30.0)
		var h := base_height + _hash(i * 13 + seed) * spread
		var top := 226.0 - h
		_root.draw_rect(Rect2(x, top, w, h), color)
		for wy in range(int(top) + 5, 222, 6):
			for wx in range(int(x) + 3, int(x + w) - 3, 4):
				if _hash(wx * 3 + wy * 7 + seed) > 0.9:
					_root.draw_rect(Rect2(wx, wy, 2, 2), LIT)
		if h > base_height + spread * 0.7 and int(_time * 1.2 + i) % 2 == 0:
			_root.draw_rect(Rect2(x + w - 3, top - 2, 2, 2), Color("#ff3b2f"))
		x += w + 2.0
		i += 1


func _label(text: String, pos: Vector2, size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.size = Vector2(480, size + 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.modulate = color
	add_child(label)


static func _hash(i: float) -> float:
	var s := sin(i * 12.9898 + 78.233) * 43758.5453
	return s - floorf(s)
