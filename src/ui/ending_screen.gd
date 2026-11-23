class_name EndingScreen
extends CanvasLayer
## The thin tragic ending (story 006): the last occupied building in the Centro
## burning in the rain, the fire the only strong light, while the ending text
## comes in line by line; then the epilogue, Zack's burner phone on the wet
## ground lighting up with "novo contrato disponível". Texts come from
## assets/data/dispatcher_messages.json ("ending", "epilogue"). Click or Enter
## shows the whole text at once, then moves on; at the end `finished` fires.
##
## Usage: var ending := EndingScreen.new(); add_child(ending); ending.finished.connect(_to_title)

## The player has seen the epilogue and closed it.
signal finished

enum Part { ENDING, EPILOGUE }

const LINE_DELAY := 1.6
const SKY_TOP := Color("#0b0c10")
const SKY_LOW := Color("#2a1812")
const BUILDING := Color("#121115")
const FIRE_DEEP := Color("#c8401c")
const FIRE := Color("#ff7a2a")
const FIRE_HOT := Color("#ffc46a")
const TEXT := Color("#d8d4cc")
const PHONE_LIGHT := Color("#cfe8d8")

var part := Part.ENDING

var _root: Control
var _text: Label
var _hint: Label
var _lines := PackedStringArray()
var _shown := 0
var _time := 0.0
var _part_time := 0.0
var _rng := RandomNumberGenerator.new()
var _embers: Array[Vector3] = []  # x, y, life
var _demo := false


func _ready() -> void:
	layer = 35
	_rng.seed = 7
	_root = Control.new()
	_root.size = Vector2(480, 270)
	_root.draw.connect(_draw_scene)
	add_child(_root)
	_text = Label.new()
	_text.position = Vector2(30, 176)
	_text.size = Vector2(420, 60)
	_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override("font_size", 8)
	_text.add_theme_color_override("font_shadow_color", Color.BLACK)
	_text.add_theme_constant_override("shadow_offset_x", 1)
	_text.add_theme_constant_override("shadow_offset_y", 1)
	_text.modulate = TEXT
	add_child(_text)
	_hint = Label.new()
	_hint.position = Vector2(0, 252)
	_hint.size = Vector2(480, 10)
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hint.add_theme_font_size_override("font_size", 6)
	_hint.modulate = Color(TEXT, 0.55)
	add_child(_hint)
	_demo = "--demo=ending" in OS.get_cmdline_user_args()
	_start(Part.ENDING)


func _start(which: Part) -> void:
	part = which
	_part_time = 0.0
	_shown = 0
	var msg := Messages.get_message("ending" if which == Part.ENDING else "epilogue")
	_lines = msg["lines"]
	_text.position = Vector2(30, 176) if which == Part.ENDING else Vector2(30, 40)
	_refresh_text()


func _process(delta: float) -> void:
	_time += delta
	_part_time += delta
	var due := mini(_lines.size(), int(_part_time / LINE_DELAY) + 1)
	if due != _shown:
		_shown = due
		_refresh_text()
	_update_embers(delta)
	_root.queue_redraw()
	if _part_time < 0.3:
		return
	var demo_next := _demo and _shown >= _lines.size() and _part_time > LINE_DELAY * _lines.size() + 1.5
	if demo_next or Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		if _shown < _lines.size():  # skip the reveal
			_part_time = LINE_DELAY * _lines.size()
			_shown = _lines.size()
			_refresh_text()
		elif part == Part.ENDING:
			_start(Part.EPILOGUE)
		else:
			finished.emit()


func _refresh_text() -> void:
	var visible := PackedStringArray()
	for i in _shown:
		visible.append(_lines[i])
	_text.text = "\n".join(visible)
	if part == Part.EPILOGUE:
		_text.text = ""  # the epilogue's line is on the phone's screen
	_hint.text = tr("clique ou Enter para continuar") if _shown >= _lines.size() else ""


func _update_embers(delta: float) -> void:
	if part == Part.ENDING and _rng.randf() < 0.6:
		_embers.append(Vector3(_rng.randf_range(196.0, 284.0), 70.0, _rng.randf_range(1.0, 2.2)))
	for i in _embers.size():
		var e := _embers[i]
		e.y -= delta * 40.0
		e.x += sin(_time * 3.0 + i) * delta * 12.0
		e.z -= delta
		_embers[i] = e
	_embers = _embers.filter(func(e: Vector3) -> bool: return e.z > 0.0)


func _draw_scene() -> void:
	if part == Part.ENDING:
		_draw_fire()
	else:
		_draw_phone()
	for k in 60:  # garoa over everything
		var x := fmod(_hash(k * 3.1) * 500.0 - _time * 25.0 + 500.0, 500.0) - 10.0
		var y := fmod(_hash(k * 7.7) * 270.0 + _time * (150.0 + _hash(k) * 70.0), 270.0)
		_root.draw_rect(Rect2(x, y, 1, 4), Color(0.75, 0.76, 0.8, 0.22))


func _draw_fire() -> void:
	for i in 34:
		_root.draw_rect(Rect2(0, i * 8, 480, 8), SKY_TOP.lerp(SKY_LOW, i / 34.0))
	var flicker := 0.85 + 0.15 * sin(_time * 11.0) * sin(_time * 7.3)
	var glow := FIRE
	glow.a = 0.16 * flicker
	_root.draw_circle(Vector2(240, 110), 120.0, glow)
	glow.a = 0.12 * flicker
	_root.draw_circle(Vector2(240, 110), 70.0, glow)
	var x := -6.0
	var i := 0
	while x < 480.0:  # dark neighbours, lit only by the fire
		var w := 24.0 + floorf(_hash(i * 7) * 26.0)
		var h := 60.0 + _hash(i * 13) * 60.0
		if x + w < 190.0 or x > 290.0:
			_root.draw_rect(Rect2(x, 170.0 - h, w, h), BUILDING)
		x += w + 2.0
		i += 1
	var tower := Rect2(200, 70, 80, 100)  # the last occupied building
	_root.draw_rect(tower, Color("#1a1518"))
	for wy in range(78, 166, 10):
		for wx in range(206, 274, 12):
			var heat := _hash(wx * 3 + wy * 7)
			var c := FIRE_DEEP.lerp(FIRE_HOT, heat * flicker) if heat > 0.25 else Color("#0e0c0e")
			_root.draw_rect(Rect2(wx, wy, 6, 6), c)
	for k in 9:  # flames over the roof
		var fx := 204.0 + k * 9.0
		var fh := 14.0 + 10.0 * absf(sin(_time * 6.0 + k * 1.7))
		_root.draw_colored_polygon(PackedVector2Array([Vector2(fx, 70), Vector2(fx + 10, 70), Vector2(fx + 5, 70 - fh)]), FIRE if k % 2 else FIRE_DEEP)
		_root.draw_colored_polygon(PackedVector2Array([Vector2(fx + 3, 70), Vector2(fx + 7, 70), Vector2(fx + 5, 70 - fh * 0.5)]), FIRE_HOT)
	for e in _embers:
		_root.draw_rect(Rect2(e.x, e.y, 1, 1), Color(FIRE_HOT, clampf(e.z / 2.0, 0.0, 1.0)))
	_root.draw_rect(Rect2(0, 170, 480, 100), Color("#0d0c0f"))
	_root.draw_rect(Rect2(0, 170, 480, 1), Color("#3a2a20"))
	var reflection := FIRE  # the fire on the wet street
	reflection.a = 0.1 * flicker
	_root.draw_rect(Rect2(200, 172, 80, 30), reflection)


func _draw_phone() -> void:
	for i in 34:  # wet asphalt
		_root.draw_rect(Rect2(0, i * 8, 480, 8), Color("#0d0d10").lerp(Color("#18171b"), i / 34.0))
	var puddle := PackedVector2Array()
	for k in 32:
		var a := TAU * k / 32.0
		puddle.append(Vector2(240, 186) + Vector2(cos(a) * 190.0, sin(a) * 34.0))
	_root.draw_colored_polygon(puddle, Color(0.04, 0.04, 0.06, 0.7))
	for k in 7:  # a street light smeared in the puddle, wavering
		var lamp := Color("#ffa040")
		lamp.a = 0.05 + 0.03 * sin(_time * 2.0 + k)
		_root.draw_rect(Rect2(318 + sin(_time * 1.5 + k) * 2.0, 160 + k * 7, 14 - k, 5), lamp)
	for k in 6:  # raindrops hitting the puddle
		var t := fmod(_time * 0.9 + _hash(k) * 3.0, 1.0)
		var c := Vector2(90 + _hash(k * 5) * 300.0, 168 + _hash(k * 9) * 36.0)
		_root.draw_arc(c, 2.0 + t * 10.0, 0.0, TAU, 16, Color(0.7, 0.7, 0.75, 0.3 * (1.0 - t)), 1.0)
	var lit := _part_time > 1.0
	var buzz := Vector2(roundf(sin(_time * 60.0)), 0.0) if lit and fmod(_part_time, 1.4) < 0.5 else Vector2.ZERO
	var body := Rect2(Vector2(206, 104) + buzz, Vector2(68, 108))
	_root.draw_rect(body.grow(1), Color("#050506"))
	_root.draw_rect(body, Color("#121215"))
	_root.draw_rect(Rect2(body.position + Vector2(26, 4), Vector2(16, 2)), Color("#2a2a30"))  # speaker
	var screen := Rect2(body.position + Vector2(6, 10), Vector2(56, 40))
	_root.draw_rect(screen, Color("#1b2622") if lit else Color("#0b0e0c"))
	for row in 3:
		for col in 3:
			_root.draw_rect(Rect2(body.position + Vector2(10 + col * 17, 60 + row * 14), Vector2(13, 9)), Color("#1e1e22"))
	if lit:
		var glow := PHONE_LIGHT
		glow.a = 0.035
		_root.draw_circle(screen.get_center(), 40.0, glow)
		var line: String = _lines[0] if not _lines.is_empty() else ""
		_root.draw_multiline_string(ThemeDB.fallback_font, screen.position + Vector2(3, 15), line, HORIZONTAL_ALIGNMENT_CENTER, screen.size.x - 6, 7, 3, PHONE_LIGHT)
		if int(_time * 2.0) % 2 == 0:
			_root.draw_rect(Rect2(body.position + Vector2(48, 4), Vector2(4, 2)), Color("#d2392c"))  # notification light


static func _hash(i: float) -> float:
	var s := sin(i * 12.9898 + 78.233) * 43758.5453
	return s - floorf(s)
