extends Control
class_name PipesTrails

@export var pipe_count: int = 4

@export var step_px: float = 18.0               # grid size (bigger = chunkier geometry)
@export var speed_px_per_sec: float = 220.0     # movement speed
@export var turn_chance: float = 0.35           # chance to turn each step (0..1)

@export var line_width: float = 8.0
@export var glow_width: float = 16.0
@export var glow_alpha: float = 0.18

@export var max_points_per_pipe: int = 220      # trail length (in points)

@export var base_alpha: float = 0.95            # head opacity
@export var tail_min_alpha: float = 0.05        # tail opacity

# Offscreen + respawn behavior (no wrapping)
@export var offscreen_margin: float = 60.0      # how far past the edge before the pipe "dies"
@export var die_fade_time: float = 0.35         # seconds to fade out once dead
@export var respawn_delay_min: float = 0.10
@export var respawn_delay_max: float = 0.50

@export var palette: PackedColorArray = PackedColorArray([
	Color("#FF3B30"), Color("#34C759"), Color("#0A84FF"),
	Color("#FFD60A"), Color("#BF5AF2"), Color("#FF9F0A")
])

const DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1)
]

class Pipe:
	enum State { ALIVE, DYING, WAITING }

	var color: Color
	var dir: Vector2i
	var head: Vector2
	var points: PackedVector2Array
	var dist_accum: float

	var state: int
	var fade_left: float
	var wait_left: float
	var alpha_mul: float

	func _init() -> void:
		color = Color.WHITE
		dir = Vector2i(1, 0)
		head = Vector2.ZERO
		points = PackedVector2Array()
		dist_accum = 0.0

		state = State.ALIVE
		fade_left = 0.0
		wait_left = 0.0
		alpha_mul = 1.0

var _pipes: Array[Pipe] = []
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS

	_pipes.clear()
	for i: int in range(pipe_count):
		var p: Pipe = Pipe.new()
		_respawn_pipe(p, true)
		_pipes.append(p)

	queue_redraw()

func _process(delta: float) -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return

	var changed: bool = false

	for p: Pipe in _pipes:
		match p.state:
			Pipe.State.ALIVE:
				p.dist_accum += speed_px_per_sec * delta

				while p.dist_accum >= step_px:
					p.dist_accum -= step_px
					_step_pipe(p)
					changed = true

			Pipe.State.DYING:
				p.fade_left -= delta
				p.alpha_mul = clamp(p.fade_left / die_fade_time, 0.0, 1.0)
				changed = true

				if p.fade_left <= 0.0:
					p.state = Pipe.State.WAITING
					p.wait_left = _rng.randf_range(respawn_delay_min, respawn_delay_max)
					p.points.clear()
					p.alpha_mul = 0.0

			Pipe.State.WAITING:
				p.wait_left -= delta
				if p.wait_left <= 0.0:
					_respawn_pipe(p, false)
					changed = true

	if changed:
		queue_redraw()

func _draw() -> void:
	for p: Pipe in _pipes:
		var pts: PackedVector2Array = p.points
		var n: int = pts.size()
		if n < 2:
			continue

		for i: int in range(n - 1):
			var denom: float = float(max(1, n - 2))
			var t: float = float(i) / denom  # 0..1 from tail->head
			var a: float = lerp(tail_min_alpha, base_alpha, t) * p.alpha_mul

			# glow pass
			if glow_width > line_width and glow_alpha > 0.0:
				var gcol: Color = p.color
				gcol.a = a * glow_alpha
				draw_line(pts[i], pts[i + 1], gcol, glow_width, true)

			# main line
			var col: Color = p.color
			col.a = a
			draw_line(pts[i], pts[i + 1], col, line_width, true)

func _step_pipe(p: Pipe) -> void:
	# Decide direction: straight or 90-degree turn
	if _rng.randf() < turn_chance:
		var left: Vector2i = Vector2i(-p.dir.y, p.dir.x)
		var right: Vector2i = Vector2i(p.dir.y, -p.dir.x)
		p.dir = left if _rng.randf() < 0.5 else right
	else:
		# occasional re-randomize to avoid very long boring lines
		if _rng.randf() < 0.02:
			p.dir = DIRS[_rng.randi_range(0, DIRS.size() - 1)]

	# Move head one step (NO wrapping)
	p.head = p.head + Vector2(p.dir) * step_px
	p.points.append(p.head)

	# Trim trail
	while p.points.size() > max_points_per_pipe:
		p.points.remove_at(0)

	# If far offscreen, start dying
	if _is_far_offscreen(p.head):
		p.state = Pipe.State.DYING
		p.fade_left = die_fade_time

func _is_far_offscreen(v: Vector2) -> bool:
	return (
		v.x < -offscreen_margin or v.x > size.x + offscreen_margin or
		v.y < -offscreen_margin or v.y > size.y + offscreen_margin
	)

func _respawn_pipe(p: Pipe, first_time: bool) -> void:
	p.state = Pipe.State.ALIVE
	p.alpha_mul = 1.0
	p.fade_left = 0.0
	p.wait_left = 0.0
	p.dist_accum = 0.0

	p.color = _pick_color()
	p.dir = DIRS[_rng.randi_range(0, DIRS.size() - 1)]

	# Start just inside the screen (snapped to grid)
	p.head = _random_snapped_point()

	p.points.clear()
	p.points.append(p.head)

	# Optional: stagger initial trails slightly so they don't all start at once
	if first_time:
		p.dist_accum = _rng.randf_range(0.0, step_px)

func _pick_color() -> Color:
	if palette.size() == 0:
		return Color.WHITE
	return palette[_rng.randi_range(0, palette.size() - 1)]

func _random_snapped_point() -> Vector2:
	var x: float = _rng.randf_range(0.0, max(1.0, size.x))
	var y: float = _rng.randf_range(0.0, max(1.0, size.y))
	return _snap(Vector2(x, y))

func _snap(v: Vector2) -> Vector2:
	return Vector2(round(v.x / step_px) * step_px, round(v.y / step_px) * step_px)
