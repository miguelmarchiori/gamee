class_name Receptador
extends Thug
## Contract 1's target, the fence: fights like a knife thug, looks like the
## man in charge (bald, moustache, gold chain, white shirt) and carries the
## target marker. Killing him completes the contract.


func _init() -> void:
	kind = "receptador"


func _draw() -> void:
	super._draw()
	if alive:  # target marker: a red arrow over his head
		var y := -42.0 + roundf(sin(Engine.get_physics_frames() * 0.12) * 2.0)
		draw_colored_polygon(PackedVector2Array([Vector2(-5, y - 1), Vector2(5, y - 1), Vector2(0, y + 6)]), FigurePainter.OUTLINE)
		draw_colored_polygon(PackedVector2Array([Vector2(-3, y), Vector2(3, y), Vector2(0, y + 4)]), Color("#d2392c"))
