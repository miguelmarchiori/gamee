class_name Messages
extends RefCounted
## The phone messages and story texts, from res://assets/data/dispatcher_messages.json.
## Text never lives in code: named placeholders such as {zack} are filled in here,
## so each line stays translatable as a whole.
##
## Usage: var msg := Messages.get_message("contract_2_intro")  # {"sender": ..., "lines": [...]}

const PATH := "res://assets/data/dispatcher_messages.json"
const VALUES := {"zack": "Zack"}

static var _cache: Dictionary = {}


## The message for `key` with placeholders filled: {"sender": String, "lines": PackedStringArray}.
## A missing key returns the key itself as the only line, so it shows up in play.
static func get_message(key: String, values: Dictionary = {}) -> Dictionary:
	if _cache.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		_cache = parsed.get("messages", {}) if typeof(parsed) == TYPE_DICTIONARY else {}
	if not _cache.has(key):
		push_error("Messages: missing %s" % key)
		return {"sender": "", "lines": PackedStringArray([key])}
	var all := VALUES.duplicate()
	all.merge(values, true)
	var lines := PackedStringArray()
	for line: String in _cache[key].get("lines", []):
		lines.append(line.format(all))
	return {"sender": _cache[key].get("sender", ""), "lines": lines}
