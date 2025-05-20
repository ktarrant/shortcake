extends CharacterBody2D
class_name Player

@export var speed := 400.0
@export var jump_force := 500.0
@export var gravity := 400.0
@export var max_jumps := 5
@export var air_control_strength := 0.05
@export var fast_fall_burst := 700.0
@export var one_way_platform_layer := 3
@export var jump_cutoff_factor := 0.5
@export var character_tint := Color(1, 1, 1)
@export var is_dummy := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var overlap_area: Area2D = $OverlapArea

const Attack = preload("res://scenes/player/Attack.tscn")

var jump_count := 0
var can_fast_fall := true
var dropped_through_platform := false
var jump_cut_applied := false
var is_hanging := false  # placeholder if you return to edge grabbing
var overlapping_player_count := 0
var percent := 0

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

func get_movement_input(player_id := 0) -> Vector2:
	var stick_input := Vector2(
		Input.get_joy_axis(player_id, JOY_AXIS_LEFT_X),
		-Input.get_joy_axis(player_id, JOY_AXIS_LEFT_Y)
	)

	var keyboard_input := Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		keyboard_input.x += 1
	if Input.is_action_pressed("move_left"):
		keyboard_input.x -= 1
	if Input.is_action_pressed("move_down"):
		keyboard_input.y -= 1  # Inverted Y
	if Input.is_action_pressed("move_up"):
		keyboard_input.y += 1

	var combined := stick_input + keyboard_input
	return combined.normalized() if combined.length() >= 0.2 else Vector2.ZERO

func handle_input():
	if is_dummy:
		return

	var input_direction := get_movement_input()

	# Flip sprite based on input
	if input_direction.x != 0:
		sprite.flip_h = input_direction.x < 0

	# Apply slowdown if overlapping another player
	var slowdown_factor := 1.0
	if overlapping_player_count > 0:
		slowdown_factor = 0.7

	# Walk
	if is_on_floor():
		var floor_normal = get_floor_normal()
		var floor_right = Vector2(-floor_normal.y, floor_normal.x)
		var walk_direction = 1 if input_direction.x > 0 else (-1 if input_direction.x < 0 else 0)
		velocity = floor_right * walk_direction * speed * slowdown_factor
	else:
		if input_direction.x != 0:
			velocity.x = lerp(velocity.x, input_direction.x * speed * slowdown_factor, air_control_strength)

	# Down input: drop through platform or fast-fall
	if input_direction.y < -0.7:
		if is_on_floor() and get_floor_normal().y < -0.7 and not dropped_through_platform:
			set_collision_mask_value(one_way_platform_layer, false)
			dropped_through_platform = true
		elif not is_on_floor() and can_fast_fall:
			velocity.y += fast_fall_burst
			can_fast_fall = false

	# Jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		var jump_vector := Vector2(0, -1)
		if is_on_floor():
			jump_vector = get_floor_normal().normalized()
		velocity += jump_vector * jump_force

		jump_count += 1
		can_fast_fall = true
		jump_cut_applied = false

	if Input.is_action_just_pressed("attack"):
		var direction := Vector2.ZERO
		# Neutral attack - simple forward jab
		if is_on_floor():
			var floor_normal = get_floor_normal()
			direction = Vector2(-floor_normal.y, floor_normal.x).normalized()
			if sprite.flip_h:
				direction = -direction
		else:
			direction = Vector2(-1 if sprite.flip_h else 1, 0)  # fallback neutral direction

		perform_attack(direction)

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
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			sprite.play("walk")
		else:
			sprite.play("idle")
	else:
		if velocity.y < 0:
			if Input.is_action_pressed("jump"):
				sprite.play("jump_hold")
			else:
				sprite.play("jump_release")
		else:
			sprite.play("jump_release")

func _on_OverlapArea_body_entered(body):
	if body is Player and body != self:
		overlapping_player_count += 1

func _on_OverlapArea_body_exited(body):
	if body is Player and body != self:
		overlapping_player_count = max(overlapping_player_count - 1, 0)

func respawn(respawn_position: Vector2):
	velocity = Vector2.ZERO
	global_position = respawn_position

	jump_count = 0
	can_fast_fall = true
	dropped_through_platform = false
	jump_cut_applied = false
	is_hanging = false
	sprite.rotation = 0
	sprite.play("idle")

func perform_attack(direction: Vector2):
	var attack = Attack.instantiate()
	attack.owner = self
	attack.global_position = global_position + direction.normalized() * 64
	attack.knockback = direction.normalized() * 200
	add_sibling(attack)

func apply_damage(amount: int, knockback: Vector2):
	percent += amount
	velocity += knockback * (1 + percent / 100.0)  # scaled knockback
