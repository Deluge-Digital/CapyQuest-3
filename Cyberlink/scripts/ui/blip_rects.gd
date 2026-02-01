extends Control
class_name BlipRects

@export var blip_count: int = 24

@export var color: Color = Color("#3A7BFF") # blue
@export var base_alpha: float = 0.75

@export var size_min: Vector2 = Vector2(6, 10)
@export var size_max: Vector2 = Vector2(14, 26)

@export var speed_in_min: float = 420.0
@export var speed_in_max: float = 980.0
@export var speed_out_min: float = 520.0
@export var speed_out_max: float = 1200.0

@export var travel_depth_min: float = 20.0   # how far inside the screen it goes
@export var travel_depth_max: float = 180.0

@export var wait_time_min: float = 0.03
@export var wait_time_max: float = 0.12

@export var respawn_delay_min: float = 0.05
@export var respawn_delay_max: float = 0.35

@export var offscreen_margin: float = 40.0   # how far outside it starts/ends
@export var soft_edges: bool = true          # antialiased rectangles via draw style trick

enum State { WAITING_TO_SPAWN, FLYING_IN, PAUSING, FLYING_OUT }

class Blip:
	var state: int = State.WAITING_TO_SPAWN
	var pos: Vector2 = Vector2.ZERO
	var vel: Vector2 = Vector2.ZERO
	var half: Vector2 = Vector2(5, 8)  # half-size
	var target: Vector2 = Vector2.ZERO
	var timer: float = 0.0
	var alpha_mul: float = 0.0

var _rng := RandomNumberGenerator.new()
var _blips: Array[Blip] = []

func _ready() -> void:
	_rng.randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_blips.clear()
	for i in range(blip_count):
		var b := Blip.new()
		_schedule_spawn(b, true)
		_blips.append(b)

	queue_redraw()

func _process(delta: float) -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return

	var changed := false

	for b in _blips:
		match b.state:
			State.WAITING_TO_SPAWN:
				b.timer -= delta
				if b.timer <= 0.0:
					_spawn(b)
				changed = true

			State.FLYING_IN:
				b.pos += b.vel * delta
				b.alpha_mul = min(1.0, b.alpha_mul + delta * 10.0)

				# arrived / passed target along movement axis
				if _reached_target(b):
					b.pos = b.target
					b.state = State.PAUSING
					b.timer = _rng.randf_range(wait_time_min, wait_time_max)
					b.vel = Vector2.ZERO
				changed = true

			State.PAUSING:
				b.timer -= delta
				if b.timer <= 0.0:
					_begin_fly_out(b)
				changed = true

			State.FLYING_OUT:
				b.pos += b.vel * delta
				b.alpha_mul = max(0.0, b.alpha_mul - delta * 6.0)

				if _is_far_offscreen(b.pos, b.half):
					_schedule_spawn(b, false)
				changed = true

	if changed:
		queue_redraw()

func _draw() -> void:
	var c := color
	for b in _blips:
		if b.alpha_mul <= 0.0:
			continue
		c.a = base_alpha * b.alpha_mul

		var rect := Rect2(b.pos - b.half, b.half * 2.0)

		# Godot doesn't have AA rects directly; this flag mainly affects lines.
		# This still looks nice because they're small and moving.
		draw_rect(rect, c, true)

func _schedule_spawn(b: Blip, first_time: bool) -> void:
	b.state = State.WAITING_TO_SPAWN
	b.alpha_mul = 0.0
	b.vel = Vector2.ZERO

	# stagger initial spawn so they don't all pop at once
	if first_time:
		b.timer = _rng.randf_range(0.0, respawn_delay_max)
	else:
		b.timer = _rng.randf_range(respawn_delay_min, respawn_delay_max)

func _spawn(b: Blip) -> void:
	# size
	var w := _rng.randf_range(size_min.x, size_max.x)
	var h := _rng.randf_range(size_min.y, size_max.y)
	b.half = Vector2(w * 0.5, h * 0.5)

	# choose edge and set start/target/velocity
	var edge := _rng.randi_range(0, 3) # 0=L,1=R,2=T,3=B
	var depth := _rng.randf_range(travel_depth_min, travel_depth_max)

	match edge:
		0: # left
			var y := _rng.randf_range(0.0, size.y)
			b.pos = Vector2(-offscreen_margin - b.half.x, y)
			b.target = Vector2(depth, y)
			b.vel = Vector2(_rng.randf_range(speed_in_min, speed_in_max), 0)

		1: # right
			var y := _rng.randf_range(0.0, size.y)
			b.pos = Vector2(size.x + offscreen_margin + b.half.x, y)
			b.target = Vector2(size.x - depth, y)
			b.vel = Vector2(-_rng.randf_range(speed_in_min, speed_in_max), 0)

		2: # top
			var x := _rng.randf_range(0.0, size.x)
			b.pos = Vector2(x, -offscreen_margin - b.half.y)
			b.target = Vector2(x, depth)
			b.vel = Vector2(0, _rng.randf_range(speed_in_min, speed_in_max))

		3: # bottom
			var x := _rng.randf_range(0.0, size.x)
			b.pos = Vector2(x, size.y + offscreen_margin + b.half.y)
			b.target = Vector2(x, size.y - depth)
			b.vel = Vector2(0, -_rng.randf_range(speed_in_min, speed_in_max))

	b.state = State.FLYING_IN
	b.alpha_mul = 0.0

func _begin_fly_out(b: Blip) -> void:
	# fly out in the opposite direction from the nearest edge it came from.
	# We infer it from which side its target is closer to.
	var vx := 0.0
	var vy := 0.0

	if b.target.x <= size.x * 0.5 and abs(b.vel.x) > 0.0:
		# came from left
		vx = -_rng.randf_range(speed_out_min, speed_out_max)
	elif b.target.x > size.x * 0.5 and abs(b.vel.x) > 0.0:
		# came from right
		vx = _rng.randf_range(speed_out_min, speed_out_max)
	elif b.target.y <= size.y * 0.5:
		# came from top
		vy = -_rng.randf_range(speed_out_min, speed_out_max)
	else:
		# came from bottom
		vy = _rng.randf_range(speed_out_min, speed_out_max)

	# Actually, the above inference is shaky because vel is zero during pause.
	# Better: determine fly-out direction from which axis has a fixed coordinate.
	# If target.x is fixed and vel was vertical, go vertical out; same for horizontal.
	# We'll use position relative to screen center:
	if abs(b.target.x - b.pos.x) < 0.001:
		# vertical blip
		vy = -_rng.randf_range(speed_out_min, speed_out_max) if b.pos.y <= size.y * 0.5 else _rng.randf_range(speed_out_min, speed_out_max)
		vx = 0.0
	else:
		# horizontal blip
		vx = -_rng.randf_range(speed_out_min, speed_out_max) if b.pos.x <= size.x * 0.5 else _rng.randf_range(speed_out_min, speed_out_max)
		vy = 0.0

	b.vel = Vector2(vx, vy)
	b.state = State.FLYING_OUT

func _reached_target(b: Blip) -> bool:
	# since motion is axis-aligned, just check along the moving axis
	if b.vel.x > 0.0:
		return b.pos.x >= b.target.x
	if b.vel.x < 0.0:
		return b.pos.x <= b.target.x
	if b.vel.y > 0.0:
		return b.pos.y >= b.target.y
	if b.vel.y < 0.0:
		return b.pos.y <= b.target.y
	return true

func _is_far_offscreen(p: Vector2, half: Vector2) -> bool:
	return (
		p.x < -offscreen_margin - half.x or p.x > size.x + offscreen_margin + half.x or
		p.y < -offscreen_margin - half.y or p.y > size.y + offscreen_margin + half.y
	)
