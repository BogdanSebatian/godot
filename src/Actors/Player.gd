extends Actor

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_tree = get_node("AnimationTree")
onready var anim_mode = anim_tree.get("parameters/playback")

var last_direction = Vector2(1.0, 0.0)

func _physics_process(_delta):
	var direction: = get_direction()
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL, true).y
	
	
func get_direction() -> Vector2:
	var direction= Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 0.0
	)
	if direction.x > 0.0:
		last_direction = Vector2(1.0, 0.0)
	elif direction.x < 0.0:
		last_direction = Vector2(-1.0, 0.0)
	return direction

func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	if direction == Vector2.ZERO:
		anim_mode.travel("Idle")
	else:
		anim_mode.travel("Run")
		anim_tree.set("parameters/Run/blend_position", direction)
		anim_tree.set("parameters/Idle/blend_position", direction)
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	print(direction.x)
	if direction.y == -1.0:
		out.y = speed.y * direction.y
		anim_mode.travel("Jump")
		anim_tree.set("parameters/Jump/blend_position", last_direction)
		anim_tree.set("parameters/Idle/blend_position", last_direction)
	if is_jump_interrupted:
		out.y = 0.0
		anim_mode.travel("Idle")
	return out
