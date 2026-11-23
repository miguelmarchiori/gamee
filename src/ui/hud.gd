class_name Hud
extends CanvasLayer
## The contract HUD: contract and place on the left, room number in the middle,
## room time and total time on the right, deaths and what Zack holds below,
## and a centre line for short messages ("SALA LIMPA", "MORTO").
##
## Usage: var hud := Hud.new(); add_child(hud); hud.set_contract("CONTRATO 1", "Galeria")

const TEXT := Color("#d8d4cc")
const RED := Color("#d2392c")
const AMBER := Color("#ffb347")
const ITEM_NAMES := {"": "-", "bottle": "garrafa", "knife": "faca", "pistol": "pistola"}

var _title: Label
var _room: Label
var _time: Label
var _status: Label
var _center: Label


func _ready() -> void:
	var bar := ColorRect.new()
	bar.color = Color(0.02, 0.02, 0.03, 0.65)
	bar.position = Vector2.ZERO
	bar.size = Vector2(480, 24)
	add_child(bar)
	var line := ColorRect.new()
	line.color = Color(RED, 0.8)
	line.position = Vector2(0, 24)
	line.size = Vector2(480, 1)
	add_child(line)
	_title = _label(Vector2(6, 3), TEXT, HORIZONTAL_ALIGNMENT_LEFT, 220)
	_room = _label(Vector2(190, 3), AMBER, HORIZONTAL_ALIGNMENT_CENTER, 100)
	_time = _label(Vector2(294, 3), TEXT, HORIZONTAL_ALIGNMENT_RIGHT, 180)
	_status = _label(Vector2(6, 13), TEXT, HORIZONTAL_ALIGNMENT_LEFT, 468)
	_center = _label(Vector2(0, 120), TEXT, HORIZONTAL_ALIGNMENT_CENTER, 480, 12)


## Sets the contract title and place shown on the left.
func set_contract(title: String, place: String) -> void:
	_title.text = "%s · %s" % [title, place]


## Updates room number, times, deaths and the held item.
func update_status(room_number: int, room_count: int, room_time: float, total_time: float, deaths: int, held: String, ammo: int) -> void:
	_room.text = tr("SALA %d/%d") % [room_number, room_count]
	_time.text = tr("%.2fs · TOTAL %.2fs") % [room_time, total_time]
	var held_text: String = tr(ITEM_NAMES.get(held, held))
	if held == "pistol":
		held_text += " x%d" % ammo
	_status.text = tr("MORTES %d · NA MÃO: %s") % [deaths, held_text]


## Shows a short centre message; an empty string hides it.
func message(text: String, color := TEXT) -> void:
	_center.text = text
	_center.modulate = color


func _label(pos: Vector2, color: Color, align: HorizontalAlignment, width: float, size := 8) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = Vector2(width, 10)
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.modulate = color
	add_child(label)
	return label
