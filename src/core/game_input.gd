extends Node
## Autoload "GameInput": registers the game's input actions at startup, so every
## key and mouse button lives in one place (design/game-brief.md, Controls).

const KEYS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_W, KEY_SPACE, KEY_UP],
	"down": [KEY_S, KEY_DOWN],
	"dash": [KEY_SHIFT],
	"interact": [KEY_E],
	"restart": [KEY_R],
	"pause": [KEY_ESCAPE, KEY_P],
	"fullscreen": [KEY_F11],
}

const MOUSE_BUTTONS := {
	"attack": [MOUSE_BUTTON_LEFT],
	"interact": [MOUSE_BUTTON_RIGHT],
}


func _ready() -> void:
	for action: String in KEYS:
		_ensure_action(action)
		for key: Key in KEYS[action]:
			var event := InputEventKey.new()
			event.physical_keycode = key
			InputMap.action_add_event(action, event)
	for action: String in MOUSE_BUTTONS:
		_ensure_action(action)
		for button: MouseButton in MOUSE_BUTTONS[action]:
			var event := InputEventMouseButton.new()
			event.button_index = button
			InputMap.action_add_event(action, event)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("fullscreen"):
		var mode := DisplayServer.window_get_mode()
		var full := mode == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if full else DisplayServer.WINDOW_MODE_FULLSCREEN)


func _ensure_action(action: String) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
