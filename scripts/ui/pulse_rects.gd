extends Control
class_name PulseRects

@export var rect_count: int = 11

@export var color: Color = Color("#00F5FF") # cyan
@export var base_alpha: float = 0.35

# Vast size range: some tiny, some big
@export var size_min: Vector2 = Vector2(14.0, 14.0)
@export var size_max: Vector2 = Vector2(520.0, 320.0)

# How fast they expand/shrink
@export var expand_time_min: float = 0.10
@export var expand_time_max: float = 0.35
@export var hold_time_min: float = 0.03
@export var hold_time_max: float = 0.20
@export var shrink_time_min: float = 0.10
@export var shrink_time_max: float = 0.40

# Delay before a new one appears again
@export var respawn_delay_min: float = 0.05
@export var respawn_delay_max: float = 0.45

# Keep some padding from the edge
@export var edge_padding: float = 10.0

# Bias toward smaller rectangles (still allows big ones)
@export var bias_small: bool = true
@export var small_bias_power: float = 2.2 # higher => more smalls

# Border settings
@export var use_border: bool = true
@export var border_thickness: float = 2.0
@export var border_color: Color = Color("#B9FFFF") # lighter cyan
@export var border_alpha_mul: float = 0.9

# Optional: a tiny rotation wobble for life (set to 0 for none)
@export var rotation_deg_max: float = 6.0

enum State { WAITING, EXPANDING, HOLDING, SHRINKING }

class Pulse:
	var state: int = State.WAITING
	var center: Vector2 = Vector2.ZERO
	var full_size: Vector2 = Vector2(80.0, 60.0)
	var scale: float = 0.0
	var timer: float = 0.0

	var expand_time: float = 0.2
	var hold_time: float = 0.08
	var shrink_time: float = 0.25

	var alpha_mul: float = 0.0
	var rot: float = 0.0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _pulses: Array[Pulse] = []

func _ready() -> void:
	_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_pulses.clear()
	for i: int in range(rect_count):
		var p: Pulse = Pulse.new()
		_schedule_spawn(p, true)
		_pulses.append(p)

	queue_redraw()

func _process(delta: float) -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return

	var changed: bool = false

	for p: Pulse in _pulses:
		match p.state:
			State.WAITING:
				p.timer -= delta
				if p.timer <= 0.0:
					_spawn(p)
				changed = true

			State.EXPANDING:
				p.timer += delta
				var denom: float = max(0.0001, p.expand_time)
				var t: float = min(1.0, p.timer / denom)
				var eased: float = _ease_out_cubic(t)
				p.scale = eased
				p.alpha_mul = eased

				if t >= 1.0:
					p.state = State.HOLDING
					p.timer = p.hold_time
				changed = true

			State.HOLDING:
				p.timer -= delta
				if p.timer <= 0.0:
					p.state = State.SHRINKING
					p.timer = 0.0
				changed = true

			State.SHRINKING:
				p.timer += delta
				var denom2: float = max(0.0001, p.shrink_time)
				var t2: float = min(1.0, p.timer / denom2)
				var eased2: float = _ease_in_cubic(1.0 - t2) # 1 -> 0
				p.scale = eased2
				p.alpha_mul = eased2

				if t2 >= 1.0:
					_schedule_spawn(p, false)
				changed = true

	if changed:
		queue_redraw()

func _draw() -> void:
	var fill: Color = color
	var stroke: Color = border_color

	for p: Pulse in _pulses:
		if p.alpha_mul <= 0.0:
			continue

		var a: float = base_alpha * p.alpha_mul
		fill.a = a

		# scale sizes
		var s: Vector2 = p.full_size * p.scale
		if s.x < 0.5 or s.y < 0.5:
			continue

		# local-space rect centered on (0,0)
		var rect_fill: Rect2 = Rect2(-s * 0.5, s)

		draw_set_transform(p.center, p.rot, Vector2.ONE)

		if use_border and border_thickness > 0.0:
			# border rect is slightly bigger
			var bt: float = border_thickness
			var s2: Vector2 = s + Vector2(bt * 2.0, bt * 2.0)
			var rect_border: Rect2 = Rect2(-s2 * 0.5, s2)

			stroke.a = a * border_alpha_mul
			draw_rect(rect_border, stroke, true)

		draw_rect(rect_fill, fill, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _schedule_spawn(p: Pulse, first_time: bool) -> void:
	p.state = State.WAITING
	p.scale = 0.0
	p.alpha_mul = 0.0

	var delay: float
	if first_time:
		delay = _rng.randf_range(0.0, respawn_delay_max)
	else:
		delay = _rng.randf_range(respawn_delay_min, respawn_delay_max)

	p.timer = delay

func _spawn(p: Pulse) -> void:
	# times
	p.expand_time = _rng.randf_range(expand_time_min, expand_time_max)
	p.hold_time = _rng.randf_range(hold_time_min, hold_time_max)
	p.shrink_time = _rng.randf_range(shrink_time_min, shrink_time_max)

	# size
	p.full_size = _random_size()

	# position (clamped to stay onscreen)
	var half: Vector2 = p.full_size * 0.5
	var min_x: float = edge_padding + half.x
	var max_x: float = max(min_x, size.x - edge_padding - half.x)
	var min_y: float = edge_padding + half.y
	var max_y: float = max(min_y, size.y - edge_padding - half.y)

	p.center = Vector2(
		_rng.randf_range(min_x, max_x),
		_rng.randf_range(min_y, max_y)
	)

	# rotation
	var deg: float = _rng.randf_range(-rotation_deg_max, rotation_deg_max)
	p.rot = deg_to_rad(deg)

	# start anim
	p.state = State.EXPANDING
	p.timer = 0.0
	p.scale = 0.0
	p.alpha_mul = 0.0

func _random_size() -> Vector2:
	# Using explicit float math to avoid Variant inference from pow()
	var rx: float = _rng.randf()
	var ry: float = _rng.randf()

	if bias_small:
		rx = exp(log(max(rx, 0.000001)) * small_bias_power)
		ry = exp(log(max(ry, 0.000001)) * small_bias_power)

	var w: float = lerp(size_min.x, size_max.x, rx)
	var h: float = lerp(size_min.y, size_max.y, ry)
	return Vector2(w, h)

func _ease_out_cubic(t: float) -> float:
	var u: float = 1.0 - t
	return 1.0 - u * u * u

func _ease_in_cubic(t: float) -> float:
	return t * t * t
