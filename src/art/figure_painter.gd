class_name FigurePainter
extends RefCounted
## Paints the game's pixel-art people out of rectangles, outlined and mirrored by
## facing. Feet sit at the given origin. Ported from the approved browser spike
## (see design/game-brief.md and production/epics/zack-reddman/story-001).

const OUTLINE := Color("#050506")

## Zack Reddman (references/zack-reddman.png): dark hoodie, jeans, light sneakers,
## hand wraps, green right eye, blind left eye and the burn on the left side.
const ZACK := {
	"coat": Color("#2a2a2f"), "coat_d": Color("#19191c"), "coat_hi": Color("#4c4c53"),
	"pants": Color("#232a38"), "pants_d": Color("#171c26"),
	"skin": Color("#e09a7a"), "skin_d": Color("#b0705a"), "hair": Color("#1b1b1d"),
	"accent": Color("#3a3a40"), "boots": Color("#cfcac0"), "boots_hi": Color("#f2efe8"),
	"glove": Color("#e8e2d4"), "belt": Color("#19191c"),
	"burn": Color("#a8463a"), "eye": Color("#3fae5a"), "blind": Color("#f2f0ea"),
}
const THUG := {
	"coat": Color("#6e4a2c"), "coat_d": Color("#4a301b"), "coat_hi": Color("#9c6c44"),
	"pants": Color("#2a2a30"), "pants_d": Color("#1c1c22"),
	"skin": Color("#c98e6a"), "skin_d": Color("#9a6648"), "hair": Color("#2a3a2a"),
	"accent": Color("#d8d0b8"), "boots": Color("#1a1a1a"), "boots_hi": Color("#444444"),
	"glove": Color("#c98e6a"), "belt": Color("#2a1a0a"),
}
const GUNNER := {
	"coat": Color("#2e3440"), "coat_d": Color("#1d222b"), "coat_hi": Color("#56606f"),
	"pants": Color("#1d222b"), "pants_d": Color("#13171e"),
	"skin": Color("#d8a280"), "skin_d": Color("#a8765a"), "hair": Color("#0e1014"),
	"accent": Color("#6e1c20"), "boots": Color("#0a0a0a"), "boots_hi": Color("#333333"),
	"glove": Color("#d8a280"), "belt": Color("#0e1014"),
}


## Paints one figure on `canvas`. `kind` is "zack", "thug" or "gunner". `state` may
## hold phase, vx, landed, aim_y, roll_progress, flip, live_fist, tint and alpha:
## a tint draws a flat silhouette (afterimages) instead of the outlined figure.
static func paint(canvas: CanvasItem, feet: Vector2, facing: int, pose: String, kind: String, state: Dictionary = {}) -> void:
	var pal: Dictionary = {"zack": ZACK, "thug": THUG, "gunner": GUNNER}.get(kind, ZACK)
	var p := _shared
	p.reset(feet.round(), 1 if facing >= 0 else -1)
	match pose:
		"dead":
			_dead(p, pal)
		"roll":
			_ball(p, pal, state)
		_:
			_standing(p, pal, kind, pose, state)
	var alpha: float = state.get("alpha", 1.0)
	if state.has("tint"):
		var tint: Color = state["tint"]
		tint.a *= alpha
		for item: Array in p.list:
			canvas.draw_rect(item[0], tint)
		return
	var outline := OUTLINE
	outline.a *= alpha
	for item: Array in p.list:
		canvas.draw_rect((item[0] as Rect2).grow(1.0), outline)
	for item: Array in p.list:
		var c: Color = item[1]
		c.a *= alpha
		canvas.draw_rect(item[0], c)


static func _dead(p: _Rects, pal: Dictionary) -> void:
	p.r(-10, -4, 16, 4, pal["coat"])
	p.r(-10, -4, 16, 1, pal["coat_hi"])
	p.r(-13, -3, 3, 3, pal["boots"])
	p.r(6, -5, 5, 5, pal["skin"])
	p.r(6, -5, 5, 2, pal["hair"])


static func _ball(p: _Rects, pal: Dictionary, s: Dictionary) -> void:
	var lift := -6.0 if s.get("flip", false) else 0.0
	var ang: float = float(s.get("roll_progress", 0.0)) * TAU - PI / 2.0
	var ox := roundf(cos(ang) * 4.0)
	var oy := roundf(sin(ang) * 4.0)
	p.r(-5, -11 + lift, 10, 10, pal["coat"])
	p.r(-4, -12 + lift, 8, 1, pal["coat"])
	p.r(-4, -1 + lift, 8, 1, pal["coat"])
	p.r(-5, -11 + lift, 10, 1, pal["coat_hi"])
	p.r(-1 - ox, -7 - oy + lift, 4, 3, pal["boots"])
	p.r(-2 + ox, -8 + oy + lift, 5, 5, pal["skin"])
	p.r(-2 + ox, -8 + oy + lift, 5, 1, pal["hair"])
	p.r(-4, -6 + lift, 8, 1, pal["accent"])


static func _standing(p: _Rects, pal: Dictionary, kind: String, pose: String, s: Dictionary) -> void:
	var t: float = s.get("phase", 0.0)
	var bob := 0.0
	match pose:
		"run":
			var s1 := sin(t)
			var c1 := cos(t)
			var l1 := roundf(s1 * 3.0)
			var l2 := -l1
			var lift1 := roundf(c1 * 2.0) if c1 > 0.0 else 0.0
			var lift2 := roundf(-c1 * 2.0) if c1 < 0.0 else 0.0
			p.r(-3 + l2, -8 - lift2, 3, 7, pal["pants_d"])
			p.r(-3 + l2, -2 - lift2, 4, 2, pal["boots"])
			p.r(0 + l1, -8 - lift1, 3, 7, pal["pants"])
			p.r(0 + l1, -2 - lift1, 4, 2, pal["boots"])
			p.r(0 + l1, -2 - lift1, 4, 1, pal["boots_hi"])
			bob = -1.0 if absf(s1) > 0.7 else 0.0
		"air":
			p.r(-4, -10, 3, 6, pal["pants_d"])
			p.r(-4, -5, 4, 2, pal["boots"])
			p.r(1, -9, 3, 5, pal["pants"])
			p.r(1, -5, 4, 2, pal["boots"])
			p.r(1, -5, 4, 1, pal["boots_hi"])
		"wall":
			p.r(-2, -9, 3, 7, pal["pants"])
			p.r(-2, -3, 4, 2, pal["boots"])
			p.r(1, -7, 3, 4, pal["pants_d"])
			p.r(2, -4, 3, 2, pal["boots"])
		_:
			p.r(-3, -8, 3, 8, pal["pants_d"])
			p.r(1, -8, 3, 8, pal["pants"])
			p.r(-4, -2, 4, 2, pal["boots"])
			p.r(1, -2, 4, 2, pal["boots"])
			p.r(1, -2, 4, 1, pal["boots_hi"])
	var y0 := bob + (1.0 if float(s.get("landed", 0.0)) > 0.0 else 0.0)
	var lean := 1.0 if pose == "attack" or pose == "slash" else 0.0
	if kind == "zack" or kind == "thug":  # coat tail, swings with speed
		var flap := minf(4.0, roundf(absf(float(s.get("vx", 0.0))) / 60.0))
		var tail := 9.0 if kind == "zack" else 5.0
		p.r(-5 - flap, -10 + y0, 4 + flap, maxf(3.0, tail - flap), pal["coat_d"])
	p.r(-4 + lean, -18 + y0, 8, 10, pal["coat"])
	p.r(-4 + lean, -18 + y0, 8, 1, pal["coat_d"])
	p.r(2 + lean, -17 + y0, 1, 9, pal["coat_hi"])
	p.r(-4 + lean, -9 + y0, 8, 1, pal["belt"])
	if kind == "gunner":
		p.r(-1 + lean, -18 + y0, 3, 2, Color("#dcdcdc"))
		p.r(0 + lean, -17 + y0, 1, 6, pal["accent"])
	if kind == "zack":  # hood down on the back, hoodie pocket
		p.r(-5 + lean, -19 + y0, 4, 3, pal["coat_d"])
		p.r(-4 + lean, -12 + y0, 8, 1, pal["coat_d"])
	_head(p, pal, kind, -3 + lean, -24 + y0)
	_arms(p, pal, kind, pose, s, y0)


static func _head(p: _Rects, pal: Dictionary, kind: String, hx: float, hy: float) -> void:
	p.r(hx, hy, 6, 6, pal["skin"])
	p.r(hx, hy + 5, 6, 1, pal["skin_d"])
	p.r(hx + 5, hy + 4, 1, 1, pal["skin_d"])
	match kind:
		"zack":
			p.r(hx - 1, hy - 1, 7, 3, pal["hair"])
			p.r(hx - 2, hy, 2, 2, pal["hair"])
			p.r(hx + 3, hy - 2, 3, 1, pal["hair"])
			p.r(hx - 1, hy + 1, 2, 4, pal["hair"])
			p.r(hx + 1, hy + 2, 2, 1, pal["hair"])  # fringe over the forehead
			p.r(hx + 5, hy, 1, 2, pal["hair"])
			p.r(hx + 2, hy + 3, 1, 1, pal["eye"])  # right eye, green
			p.r(hx + 4, hy + 2, 2, 4, pal["burn"])  # the burn
			p.r(hx + 3, hy + 5, 2, 1, pal["burn"])
			p.r(hx + 4, hy + 3, 1, 1, pal["blind"])  # left eye, blind
		"thug":
			p.r(hx - 1, hy - 1, 7, 3, pal["hair"])
			p.r(hx + 5, hy + 1, 3, 1, pal["hair"])
			p.r(hx - 1, hy + 2, 2, 2, Color("#1a1208"))
			p.r(hx + 4, hy + 3, 1, 1, Color("#111111"))
			p.r(hx + 1, hy + 5, 4, 1, Color("#5a3a28"))
		"gunner":
			p.r(hx, hy - 1, 6, 2, pal["hair"])
			p.r(hx - 1, hy, 1, 3, pal["hair"])
			p.r(hx + 2, hy + 2, 4, 2, Color("#0a0a10"))
			p.r(hx + 5, hy + 2, 1, 1, Color("#77ffff"))


static func _arms(p: _Rects, pal: Dictionary, kind: String, pose: String, s: Dictionary, y0: float) -> void:
	match pose:
		"attack":
			if s.get("live_fist", false):  # the punching arm is drawn apart, toward the aim
				p.r(-3, -16 + y0, 2, 5, pal["coat_d"])
				p.r(-3, -12 + y0, 3, 3, pal["glove"])
			elif float(s.get("aim_y", 0.0)) < 0.0:
				p.r(1, -28 + y0, 3, 10, pal["coat"])
				p.r(1, -30 + y0, 3, 3, pal["glove"])
			elif float(s.get("aim_y", 0.0)) > 0.0:
				p.r(2, -12 + y0, 8, 3, pal["coat"])
				p.r(10, -11 + y0, 3, 3, pal["glove"])
			else:
				p.r(3, -16 + y0, 8, 3, pal["coat"])
				p.r(11, -16 + y0, 3, 3, pal["glove"])
		"wall":
			p.r(3, -25, 2, 9, pal["coat"])
			p.r(3, -27, 2, 2, pal["glove"])
		"aim":
			p.r(2, -16, 6, 2, pal["coat"])
			p.r(8, -17, 6, 2, Color("#b8bed0"))
			p.r(8, -15, 2, 2, Color("#555a6a"))
			p.r(13, -17, 1, 1, Color.WHITE)
		"windup":
			p.r(-1, -22, 2, 6, pal["coat"])
			p.r(-1, -29, 2, 7, Color("#e8eef8"))
			p.r(-1, -23, 2, 1, Color("#5a3a20"))
		"slash":
			p.r(3, -16, 6, 2, pal["coat"])
			p.r(9, -17, 10, 2, Color.WHITE)
		_:
			var sw := roundf(-sin(float(s.get("phase", 0.0))) * 2.0) if pose == "run" else 0.0
			p.r(-1 + sw, -17 + y0, 2, 7, pal["coat_d"])
			p.r(-1 + sw, -10 + y0, 2, 2, pal["glove"])
			if kind == "gunner":
				p.r(1, -10 + y0, 4, 2, Color("#9aa0b4"))
			if kind == "thug":
				p.r(1 + sw, -11 + y0, 1, 4, Color("#e8eef8"))


static var _shared := _Rects.new()


## Collects a figure's rectangles in local pixels, mirrored by facing. One
## instance is reused for every figure so painting does not allocate a new one.
class _Rects:
	var origin := Vector2.ZERO
	var facing := 1
	var list: Array = []

	func reset(o: Vector2, f: int) -> void:
		origin = o
		facing = f
		list.clear()

	func r(dx: float, dy: float, w: float, h: float, c: Color) -> void:
		var x := origin.x + dx if facing > 0 else origin.x - dx - w
		list.append([Rect2(x, origin.y + dy, w, h), c])
