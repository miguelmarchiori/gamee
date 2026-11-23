extends Node
## Autoload "Tuning": every gameplay number lives in res://assets/data/tuning.json
## and is read through here, so balance changes never touch code.

const PATH := "res://assets/data/tuning.json"

var _data: Dictionary = {}


func _ready() -> void:
	reload()


## Re-reads the tuning file. Returns false when it could not be read or parsed.
func reload() -> bool:
	var text := FileAccess.get_file_as_string(PATH)
	if text.is_empty():
		push_error("Tuning: could not read %s" % PATH)
		return false
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Tuning: %s is not a JSON object" % PATH)
		return false
	_data = parsed
	return true


## One value from one section of the tuning file, e.g. value("player", "run_speed").
func value(section: String, key: String) -> float:
	var part: Dictionary = _data.get(section, {})
	if not part.has(key):
		push_error("Tuning: missing %s.%s" % [section, key])
		return 0.0
	return float(part[key])
