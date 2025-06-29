extends CharacterBody2D
class_name Player

@export var speed := 400.0
@export var jump_force := 400.0
@export var gravity := 400.0
@export var max_jumps := 5
@export var air_control_strength := 0.05
@export var fast_fall_burst := 800.0
@export var one_way_platform_layer := 3
@export var slope_walk_angle := 0.1
@export var is_dummy := false
@export var walk_speed_fraction := 0.7
@export var run_threshold := 0.70
@export var jump_extend_max_time := 1.0
@export var character_tint := Color(1, 1, 1)
@export var player_id := 0
@export var max_shield_health: float = 100.0
@export var min_shield_activation: float = 25.0
@export var shield_regen_rate: float = 20.0  # per second
@export var shield_drain_rate: float = 10.0  # per second
@export var reduced_knockback_factor: float = 0.3
@export var hitstun_time_factor: float = 0.03 # 3 seconds per 100 damage
@export var max_hitstun_time: float = 1.0 # max 1 second hitstun
@export var shield_break_hitstun_time: float = 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var overlap_area: Area2D = $OverlapArea

const PlayerState = preload("res://scripts/PlayerState.gd")
const Attack = preload("res://scenes/player/Attack.tscn")

var base_velocity: Vector2 = Vector2.ZERO
var input_velocity: Vector2 = Vector2.ZERO

var jump_count := 0
var in_fast_fall := false
var dropped_through_platform := false
var overlapping_player_count := 0
var percent := 0
var shield_health: float = 100.0
var state: PlayerState = null
var player_input: String = ""
var player_joycon_id: int = 0

func _ready():
	floor_max_angle = deg_to_rad(60)
	sprite.modulate = character_tint
	change_state(PlayerState.IdleState.new())

func _physics_process(delta):
	var input_dir = get_movement_input()
	if not is_dummy:
		state.handle_input(self, input_dir)
	state.physics_update(self, delta)
	
	_global_physics_process(delta)
	
	state.update(self, delta)

	velocity = base_velocity + input_velocity
	move_and_slide()
	
	state.update_animation(self)


func _global_physics_process(delta):
	# intertia / gravity
	if is_on_floor():
		var floor_normal = get_floor_normal()
		var floor_direction = Vector2(-floor_normal.y, floor_normal.x)
		base_velocity.x = lerp(base_velocity.x, 0.0, 0.3)
		if abs(base_velocity.x) < 5.0:
			base_velocity.x = 0
		elif base_velocity.x > 0:
			floor_direction = floor_direction.rotated(slope_walk_angle)
		elif base_velocity.x < 0:
			floor_direction = (-floor_direction).rotated(-slope_walk_angle)
	else:
		base_velocity.y += gravity * delta
		base_velocity.y = clamp(base_velocity.y, -INF, 1200)
		base_velocity.x = lerp(base_velocity.x, 0.0, 0.1)

func get_movement_input() -> Vector2:
	var keys := Vector2.ZERO
	if player_input == "Keyboard":
		if Input.is_action_pressed("move_right"): keys.x += 1
		if Input.is_action_pressed("move_left"): keys.x -= 1
		if Input.is_action_pressed("move_down"): keys.y -= 1
		if Input.is_action_pressed("move_up"): keys.y += 1
	elif player_input != "":
		keys = Vector2(
			Input.get_joy_axis(player_joycon_id, JOY_AXIS_LEFT_X),
			-Input.get_joy_axis(player_joycon_id, JOY_AXIS_LEFT_Y)
		)
	return keys.normalized() if keys.length() > 0.2 else Vector2.ZERO

func change_state(new_state: PlayerState):
	if state != null:
		state.exit()
	state = new_state
	state.enter(self)

func land():
	print("land()")
	# Cancel velocity into the floor to prevent jitter
	var floor_normal = get_floor_normal().normalized()
	var into_floor = base_velocity.project(floor_normal)
	base_velocity -= into_floor
	jump_count = 0
	in_fast_fall = false
	input_velocity = Vector2.ZERO
	set_collision_mask_value(one_way_platform_layer, true)
	dropped_through_platform = false

func apply_damage(amount: int, knockback: Vector2):
	if "apply_damage" in state:
		state.apply_damage(self, amount, knockback)
	else:
		percent += amount
		base_velocity += knockback * (1 + percent / 100.0)
		print("took damage: ", amount)
		var hitstun_time = min(
			hitstun_time_factor * amount * (percent / 100.0),
			max_hitstun_time)
		change_state(PlayerState.HitstunState.new(hitstun_time))

func respawn(respawn_position: Vector2):
	global_position = respawn_position
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	input_velocity = Vector2.ZERO
	jump_count = 0
	in_fast_fall = false
	dropped_through_platform = false
	percent = 0
	sprite.rotation = 0
	sprite.play("idle")
	change_state(PlayerState.IdleState.new())
