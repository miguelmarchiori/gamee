class_name PhoneMessage
extends CanvasLayer
## The burner phone: a message from the Despachante (or anyone) on a small
## screen over the dimmed game. Click, Enter or Space closes it.
##
## Usage: var phone := PhoneMessage.new(); add_child(phone)
##        phone.dismissed.connect(_go_on); phone.open(["linha 1", "linha 2"])

## The player closed the message.
signal dismissed

const BODY := Color("#0e0e11")
const SCREEN := Color("#1b2622")
const SCREEN_TEXT := Color("#cfe8d8")
const HEADER := Color("#8fb8a0")

## True while a message is on screen.
var is_open := false

var _root: Control
var _sender: Label
var _text: Label
var _hint: Label
var _opened_frame := 0


func _ready() -> void:
	layer = 50
	_root = Control.new()
	_root.size = Vector2(480, 270)
	_root.draw.connect(_draw_phone)
	add_child(_root)
	_sender = _label(Vector2(170, 64), HEADER, 8)
	_text = _label(Vector2(170, 80), SCREEN_TEXT, 8)
	_text.size = Vector2(140, 110)
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint = _label(Vector2(170, 200), Color(SCREEN_TEXT, 0.6), 6)
	_hint.text = tr("clique ou Enter para continuar")
	_set_visible(false)


## Shows `lines` from `sender` until the player closes it.
func open(lines: Array, sender := "DESPACHANTE") -> void:
	_sender.text = tr("MENSAGEM · %s") % sender
	var body := PackedStringArray()
	for line: String in lines:
		body.append(line.trim_prefix(sender + ": "))
	_text.text = "\n".join(body)
	is_open = true
	_opened_frame = Engine.get_process_frames()
	_set_visible(true)


func _process(_delta: float) -> void:
	if not is_open or Engine.get_process_frames() - _opened_frame < 10:
		return
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("attack"):
		is_open = false
		_set_visible(false)
		dismissed.emit()


func _draw_phone() -> void:
	_root.draw_rect(Rect2(0, 0, 480, 270), Color(0, 0, 0, 0.72))
	var body := Rect2(160, 40, 160, 190)
	_root.draw_rect(body.grow(1), Color("#050506"))
	_root.draw_rect(body, BODY)
	_root.draw_rect(Rect2(body.position + Vector2(64, 6), Vector2(32, 2)), Color("#2a2a30"))  # speaker
	var screen := Rect2(166, 54, 148, 160)
	_root.draw_rect(screen, SCREEN)
	_root.draw_rect(Rect2(screen.position, Vector2(screen.size.x, 22)), Color("#24332c"))
	for y in range(int(screen.position.y), int(screen.end.y), 2):  # old LCD lines
		_root.draw_rect(Rect2(screen.position.x, y, screen.size.x, 1), Color(0, 0, 0, 0.12))


func _set_visible(on: bool) -> void:
	for child in get_children():
		(child as CanvasItem).visible = on


func _label(pos: Vector2, color: Color, size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.modulate = color
	add_child(label)
	return label
