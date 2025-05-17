extends CharacterBody2D

@export var speed := 200.0
@export var jump_force := 400.0
@export var gravity := 400.0
@export var max_jumps := 5
@export var air_control_strength = 0.05
@export var fast_fall_burst := 600.0
@export var one_way_platform_layer := 2  # Matches Layer 2 used on platforms

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var jump_count := 0
var can_fast_fall := true
var dropped_through_platform := false

func _ready():
	floor_max_angle = deg_to_rad(60)  # Allows smoother contact on slopes

func _physics_process(delta):
	handle_input()
	apply_physics(delta)
	move_and_slide()
	check_grounded()
	update_animation()

func handle_input():
	var input_direction = 0

	if Input.is_action_pressed("move_left"):
		input_direction -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("move_right"):
		input_direction += 1
		sprite.flip_h = false

	# Movement logic
	if is_on_floor():
		# Move along floor direction
		var floor_normal = get_floor_normal()
		var floor_right = Vector2(-floor_normal.y, floor_normal.x)  # tangent
		velocity = floor_right * input_direction * speed
	else:
		if input_direction != 0:
			velocity.x = lerp(velocity.x, input_direction * speed, air_control_strength)

	# Jumping logic
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		if is_on_floor():
			var jump_vector = get_floor_normal().normalized()
			velocity += jump_vector * jump_force
		else:
			velocity.y = -jump_force  # Air jump is straight up

		jump_count += 1
		can_fast_fall = true  # Reset fast-fall when jumping
		
	if Input.is_action_just_pressed("move_down"):
		if is_on_floor() and get_floor_normal().y < -0.7 and not dropped_through_platform:
			# On a one-way platform (flat or close to flat)
			set_collision_mask_value(one_way_platform_layer, false)
			dropped_through_platform = true
			velocity.y += fast_fall_burst
		elif not is_on_floor() and can_fast_fall:
			velocity.y += fast_fall_burst
			can_fast_fall = false

func apply_physics(delta):
	var effective_gravity = gravity

	# Apply fast-fall if in air and holding down
	if not is_on_floor() and Input.is_action_pressed("move_down"):
		effective_gravity *= 2.0  # Adjust multiplier as desired (1.5–3 is typical)

	velocity.y += effective_gravity * delta

func check_grounded():
	if is_on_floor():
		jump_count = 0
		can_fast_fall = true  # Reset fast-fall on landing
		
	if not is_on_floor() and dropped_through_platform:
		# Wait until we're no longer overlapping platform
		var space_state = get_world_2d().direct_space_state
		var ray_params = PhysicsRayQueryParameters2D.create(global_position, global_position - Vector2(0, 4))
		ray_params.exclude = [self]

		var result = space_state.intersect_ray(ray_params)

		if result.is_empty():
			set_collision_mask_value(one_way_platform_layer, true)
			dropped_through_platform = false

func update_animation():
	var grounded = is_on_floor() or velocity.y == 0

	if not grounded:
		if sprite.animation != "jump":
			sprite.play("jump")
	elif velocity.x != 0:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")
	
	if is_on_floor():
		var normal = get_floor_normal()
		var angle = atan2(normal.x, -normal.y)
		sprite.rotation = angle
	else:
		sprite.rotation = 0.0
