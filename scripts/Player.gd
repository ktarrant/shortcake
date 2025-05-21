extends CharacterBody2D
class_name Player

@export var speed := 400.0
@export var jump_force := 600.0
@export var gravity := 400.0
@export var max_jumps := 5
@export var air_control_strength := 0.05
@export var fast_fall_burst := 800.0
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
var is_attacking := false
var overlapping_player_count := 0
var percent := 0
var was_on_floor := false

var is_in_hitstun := false
var hitstun_timer := 0.0

var base_velocity := Vector2.ZERO  # physics/knockback
var input_velocity := Vector2.ZERO  # player control

func _ready():
	floor_max_angle = deg_to_rad(60)
	sprite.modulate = character_tint

func _physics_process(delta):
	# Hitstun countdown
	if is_in_hitstun:
		hitstun_timer -= delta
		if hitstun_timer <= 0:
			is_in_hitstun = false

	handle_input()
	apply_physics(delta)
	move_and_slide()
	check_grounded()
	apply_variable_jump_cut()
	update_sprite_rotation()
	update_animation()

func get_movement_input() -> Vector2:
	var stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		-Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)

	var keys := Vector2.ZERO
	if Input.is_action_pressed("move_right"): keys.x += 1
	if Input.is_action_pressed("move_left"): keys.x -= 1
	if Input.is_action_pressed("move_down"): keys.y -= 1
	if Input.is_action_pressed("move_up"): keys.y += 1

	var combined := stick + keys
	return combined.normalized() if combined.length() > 0.2 else Vector2.ZERO

func handle_input():
	if is_dummy or is_attacking or is_in_hitstun:
		return

	var input_dir := get_movement_input()

	if input_dir.x != 0:
		sprite.flip_h = input_dir.x < 0

	var slowdown := 0.7 if overlapping_player_count > 0 else 1.0

	# Horizontal control
	if is_on_floor():
		if input_dir.x != 0:
			var floor_normal = get_floor_normal()
			var floor_direction = Vector2(-floor_normal.y, floor_normal.x)
			if input_dir.x > 0:
				floor_direction = floor_direction.rotated(0.1)
			else:
				floor_direction = (-floor_direction).rotated(-0.1)
			print("floor_direction: ", floor_direction)
			input_velocity = floor_direction * speed * slowdown
		else:
			input_velocity = Vector2.ZERO
	else:
		if input_dir.x != 0:
			input_velocity.x = lerp(input_velocity.x, input_dir.x * speed * slowdown, air_control_strength)
		else:
			input_velocity.x = lerp(input_velocity.x, 0.0, 0.1)

	# Fast-fall / drop-through
	if input_dir.y < -0.7:
		if is_on_floor() and get_floor_normal().y < -0.7 and not dropped_through_platform:
			set_collision_mask_value(one_way_platform_layer, false)
			dropped_through_platform = true
			base_velocity.y = fast_fall_burst
			can_fast_fall = false
		elif not is_on_floor() and can_fast_fall:
			base_velocity.y = fast_fall_burst
			can_fast_fall = false

	# Jump
	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		if is_on_floor():
			base_velocity = get_floor_normal().normalized() * jump_force
		else:
			base_velocity += Vector2(0, -1) * jump_force
		jump_count += 1
		can_fast_fall = true
		jump_cut_applied = false

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		is_attacking = true
		sprite.play("neutral_attack")
		var normal = get_floor_normal()
		var direction = Vector2(-normal.y, normal.x).normalized()
		if sprite.flip_h:
			direction = -direction
		perform_attack(direction)

func apply_physics(delta):
	if not is_on_floor():
		base_velocity.y += gravity * delta
	base_velocity.y = clamp(base_velocity.y, -INF, 1200)

	# Friction
	if is_on_floor() and abs(base_velocity.x) < 5.0:
		base_velocity.x = 0.0
	else:
		base_velocity.x = lerp(base_velocity.x, 0.0, 0.1)
	
	velocity = base_velocity + input_velocity

func check_grounded():
	if is_on_floor():
		jump_count = 0
		can_fast_fall = true
		jump_cut_applied = false

		if dropped_through_platform:
			set_collision_mask_value(one_way_platform_layer, true)
			dropped_through_platform = false

		# Remove velocity into the floor
		var floor_normal = get_floor_normal().normalized()
		var into_floor = base_velocity.project(floor_normal)
		base_velocity -= into_floor

func apply_variable_jump_cut():
	if not Input.is_action_pressed("jump") and base_velocity.y < 0 and not jump_cut_applied:
		base_velocity.y *= jump_cutoff_factor
		jump_cut_applied = true

func update_sprite_rotation():
	if is_on_floor():
		var normal = get_floor_normal()
		sprite.rotation = atan2(normal.x, -normal.y)
	else:
		sprite.rotation = lerp_angle(sprite.rotation, 0.0, 0.2)

func update_animation():
	if is_attacking:
		return

	if is_on_floor():
		sprite.play("walk") if abs(velocity.x) > 0.1 else sprite.play("idle")
	else:
		if base_velocity.y < 0:
			sprite.play("jump_hold") if Input.is_action_pressed("jump") else sprite.play("jump_release")
		else:
			sprite.play("jump_release")

func perform_attack(direction: Vector2):
	var attack = Attack.instantiate()
	attack.attacker = self
	attack.global_position = global_position + direction * 64
	attack.knockback = direction * 200
	get_parent().add_child(attack)

func apply_damage(amount: int, knockback: Vector2):
	percent += amount
	base_velocity += knockback * (1 + percent / 100.0)
	is_in_hitstun = true
	hitstun_timer = 0.3  # adjust for feel

func _on_AnimatedSprite2D_animation_finished():
	if sprite.animation == "neutral_attack":
		is_attacking = false

func _on_OverlapArea_body_entered(body):
	if body is Player and body != self:
		overlapping_player_count += 1

func _on_OverlapArea_body_exited(body):
	if body is Player and body != self:
		overlapping_player_count = max(overlapping_player_count - 1, 0)

func respawn(respawn_position: Vector2):
	global_position = respawn_position
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	input_velocity = Vector2.ZERO
	jump_count = 0
	can_fast_fall = true
	dropped_through_platform = false
	jump_cut_applied = false
	is_attacking = false
	is_in_hitstun = false
	hitstun_timer = 0.0
	percent = 0
	sprite.rotation = 0
	sprite.play("idle")
