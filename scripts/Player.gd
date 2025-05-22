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
@export var slope_walk_angle := 0.1
@export var is_dummy := false
@export var walk_speed_fraction := 0.7
@export var run_threshold := 0.70
@export var character_tint := Color(1, 1, 1)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var overlap_area: Area2D = $OverlapArea

const PlayerState = preload("res://scripts/PlayerState.gd")
const Attack = preload("res://scenes/player/Attack.tscn")

var base_velocity: Vector2 = Vector2.ZERO
var input_velocity: Vector2 = Vector2.ZERO

var jump_count := 0
var can_fast_fall := true
var jump_cut_applied := false
var overlapping_player_count := 0
var percent := 0

var state: PlayerState = null

func _ready():
	floor_max_angle = deg_to_rad(60)
	sprite.modulate = character_tint
	change_state(PlayerState.IdleState.new())

func _physics_process(delta):
	var input_dir = get_movement_input()
	if not is_dummy:
		state.handle_input(self, input_dir)
	state.physics_update(self, delta)
	state.update(self, delta)

	velocity = base_velocity + input_velocity
	move_and_slide()
	
	state.update_animation(self)

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

func change_state(new_state: PlayerState):
	if state != null:
		state.exit()
	state = new_state
	state.enter(self)

func land():
	# Cancel velocity into the floor to prevent jitter
	var floor_normal = get_floor_normal().normalized()
	var into_floor = base_velocity.project(floor_normal)
	base_velocity -= into_floor

func apply_damage(amount: int, knockback: Vector2):
	percent += amount
	base_velocity += knockback * (1 + percent / 100.0)
	change_state(PlayerState.HitstunState.new())

func respawn(respawn_position: Vector2):
	global_position = respawn_position
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	input_velocity = Vector2.ZERO
	jump_count = 0
	can_fast_fall = true
	jump_cut_applied = false
	percent = 0
	sprite.rotation = 0
	sprite.play("idle")
	change_state(PlayerState.IdleState.new())
