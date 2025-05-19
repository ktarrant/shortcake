extends CharacterBody2D

@export var speed := 200.0
@export var jump_force := 400.0
@export var gravity := 400.0
@export var max_jumps := 5
@export var air_control_strength := 0.05
@export var fast_fall_burst := 700.0
@export var one_way_platform_layer := 2
@export var jump_cutoff_factor := 0.7
@export var is_dummy := false
@export var character_tint := Color(1, 1, 1)  # Default = white (no tint)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var jump_count := 0
var can_fast_fall := true
var dropped_through_platform := false
var jump_cut_applied := false

func _ready():
	floor_max_angle = deg_to_rad(60)
	sprite.modulate = character_tint

func _physics_process(delta):
	handle_input()
	apply_physics(delta)
	move_and_slide()
	check_grounded()
	apply_variable_jump_cut()
	update_sprite_rotation()
	update_animation()

func handle_input():
	var input_direction := 0

	if is_dummy:
		return  # Don't process input

	if Input.is_action_pressed("move_left"):
		input_direction -= 1
		sprite.flip_h = true
	if Input.is_action_pressed("move_right"):
		input_direction += 1
		sprite.flip_h = false

	# Walk
	if is_on_floor():
		var floor_normal = get_floor_normal()
		var floor_right = Vector2(-floor_normal.y, floor_normal.x)
		velocity = floor_right * input_direction * speed
	else:
		if input_direction != 0:
			velocity.x = lerp(velocity.x, input_direction * speed, air_control_strength)

	# Down input: drop through platform or fast-fall
	if Input.is_action_just_pressed("move_down"):
		if is_on_floor() and get_floor_normal().y < -0.7 and not dropped_through_platform:
			set_collision_mask_value(one_way_platform_layer, false)
			dropped_through_platform = true
			velocity.y += fast_fall_burst
		elif not is_on_floor() and can_fast_fall:
			velocity.y += fast_fall_burst
			can_fast_fall = false

	# Jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		var jump_vector := Vector2(0, -1)  # Default to straight up

		if is_on_floor():
			jump_vector = get_floor_normal().normalized()
		velocity += jump_vector * jump_force

		jump_count += 1
		can_fast_fall = true
		jump_cut_applied = false

func apply_physics(delta):
	velocity.y += gravity * delta

func check_grounded():
	if is_on_floor():
		jump_count = 0
		can_fast_fall = true
		jump_cut_applied = false
		if dropped_through_platform:
			set_collision_mask_value(one_way_platform_layer, true)
			dropped_through_platform = false

func apply_variable_jump_cut():
	if not Input.is_action_pressed("jump") and velocity.y < 0 and not jump_cut_applied:
		velocity.y *= jump_cutoff_factor
		jump_cut_applied = true

func update_sprite_rotation():
	if is_on_floor():
		var normal = get_floor_normal()
		var angle = atan2(normal.x, -normal.y)
		sprite.rotation = angle
	else:
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, 0.2)

func update_animation():
	if not is_on_floor():
		sprite.play("jump")
	elif abs(velocity.x) > 0.1:
		sprite.play("walk")
	else:
		sprite.play("idle")
