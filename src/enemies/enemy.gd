class_name Enemy
extends CharacterBody2D
## Base for every enemy: one hit kills it, the body flies back and stays on the
## floor until the room restarts. Subclasses add behaviour in `_think`.
##
## Usage: var e := Thug.new(); e.session = session; e.position = feet; add_child(e)

const WIDTH := 10.0
const HEIGHT := 20.0
const GRAVITY := 900.0

## "thug" or "gunner": picks the look (FigurePainter) and the death drop.
var kind := "thug"
## False once it has been hit.
var alive := true
## Which way it faces: 1 right, -1 left.
var facing := -1
## The running room; set before adding to the tree.
var session: RoomSession

var _phase := 0.0


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	var shape := RectangleShape2D.new()
	shape.size = Vector2(WIDTH, HEIGHT)
	var body := CollisionShape2D.new()
	body.shape = shape
	body.position = Vector2(0.0, -HEIGHT / 2.0)
	add_child(body)


## The rectangle a punch, a bullet or a thrown item has to touch, in world pixels.
func hurtbox() -> Rect2:
	return Rect2(global_position.x - WIDTH / 2.0, global_position.y - HEIGHT, WIDTH, HEIGHT)


## Its chest, where it looks from.
func chest() -> Vector2:
	return global_position + Vector2(0.0, -15.0)


## Kills it, thrown toward `dir_x`. Called by RoomSession.kill_enemy.
func die(dir_x: float, dir_y := -0.4) -> void:
	if not alive:
		return
	alive = false
	velocity = Vector2(dir_x * 160.0, -140.0 + dir_y * 60.0)
	facing = -1 if dir_x > 0.0 else 1
	collision_layer = 0


func _physics_process(delta: float) -> void:
	if session and session.frozen():
		return
	velocity.y += GRAVITY * delta
	if alive:
		_think(delta)
	elif is_on_floor():
		velocity.x *= 0.5
	move_and_slide()
	_phase += absf(velocity.x) * delta * 0.1
	queue_redraw()


## Behaviour for one physics frame; the base enemy only stands.
func _think(_delta: float) -> void:
	velocity.x = 0.0


## The pose FigurePainter draws while alive.
func pose() -> String:
	return "idle"


func _draw() -> void:
	FigurePainter.paint(self, Vector2.ZERO, facing, pose() if alive else "dead", kind, {"phase": _phase, "vx": velocity.x})
