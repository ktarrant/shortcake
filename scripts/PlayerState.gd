extends Node
class_name PlayerState

func enter(player: Node) -> void:
	pass

func exit() -> void:
	pass

func handle_input(player: Node, input_dir: Vector2) -> void:
	pass

func update(player: Node, delta: float) -> void:
	pass

func physics_update(player: Node, delta: float) -> void:
	if player.is_on_floor():
		player.base_velocity.x = lerp(player.base_velocity.x, 0.0, 0.3)
		if abs(player.base_velocity.x) < 5.0:
			player.base_velocity.x = 0
	else:
		player.base_velocity.y += player.gravity * delta
		player.base_velocity.y = clamp(player.base_velocity.y, -INF, 1200)
		player.base_velocity.x = lerp(player.base_velocity.x, 0.0, 0.1)
	
func update_animation(player: Node) -> void:		# rotate sprite to floor
	if player.is_on_floor():
		var normal = player.get_floor_normal()
		player.sprite.rotation = atan2(normal.x, -normal.y)
	else:
		player.sprite.rotation = lerp_angle(player.sprite.rotation, 0.0, 0.2)


class IdleState:
	extends PlayerState

	func enter(player: Node) -> void:
		print("enter state: IdleState")
		player.sprite.play("idle")

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if input_dir.x != 0:
			player.change_state(RunState.new())
		elif Input.is_action_just_pressed("jump"):
			player.change_state(JumpState.new())
		else:
			player.input_velocity = Vector2.ZERO
			
	func update_animation(player: Node) -> void:
		player.sprite.play("idle")
		player.sprite.speed_scale = 1.0
		
	func physics_update(player: Node, delta: float) -> void:
		super.physics_update(player, delta)
		# Auto-transition to fall if not grounded
		if not player.is_on_floor():
			player.change_state(AirState.new())


class RunState:
	extends PlayerState

	var state_name = "RunState"
	
	func enter(player: Node) -> void:
		print("enter state: RunState")
		player.sprite.play("run")

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if input_dir.x == 0:
			player.change_state(IdleState.new())
		elif Input.is_action_just_pressed("jump"):
			player.change_state(JumpState.new())
		if input_dir.x < 0:
			player.sprite.flip_h = true
		elif input_dir.x > 0:
			player.sprite.flip_h = false
		
		var input_strength: float = abs(input_dir.x)
		var run: float = input_strength > player.run_threshold
		var current_speed: float = (
				player.speed * input_strength
				if run else
				player.speed * input_strength * player.walk_speed_fraction)
		var slowdown := 0.7 if player.overlapping_player_count > 0 else 1.0
		var floor_normal = player.get_floor_normal()
		var floor_direction = Vector2(-floor_normal.y, floor_normal.x)
		# Apply a small rotation to help smooth movement up slopes
		if input_dir.x > 0:
			floor_direction = floor_direction.rotated(player.slope_walk_angle)
		else:
			floor_direction = (-floor_direction).rotated(-player.slope_walk_angle)
		player.input_velocity = floor_direction * current_speed * slowdown

	func update_animation(player: Node) -> void:
		var input_strength: float = abs(player.get_movement_input().x)
		if input_strength > player.run_threshold:
			player.sprite.play("run")
		else:
			player.sprite.play("walk")
		player.sprite.speed_scale = clamp(abs(player.velocity.x) / player.speed, 0.5, 1.5)
		super.update_animation(player)

	func physics_update(player: Node, delta: float) -> void:
		super.physics_update(player, delta)
		# Auto-transition to fall if not grounded
		if not player.is_on_floor():
			player.change_state(AirState.new())

class AirState:
	extends PlayerState
	
	func enter(player: Node) -> void:
		print("enter state: AirState")
		player.sprite.play("jump_release")

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if input_dir.x < 0:
			player.sprite.flip_h = true
		elif input_dir.x > 0:
			player.sprite.flip_h = false

		if (Input.is_action_just_pressed("jump")
			and player.jump_count < player.max_jumps):
			player.change_state(JumpState.new())

		var slowdown := 0.7 if player.overlapping_player_count > 0 else 1.0
		if input_dir.x != 0:
			player.input_velocity.x = lerp(player.input_velocity.x,
										  input_dir.x * player.speed * slowdown,
										  player.air_control_strength)
		else:
			player.input_velocity.x = lerp(player.input_velocity.x, 0.0, 0.1)

	func physics_update(player: Node, delta: float) -> void:
		super.physics_update(player, delta)		
		if player.base_velocity.y >= 0 and player.is_on_floor():
			player.land()
			player.change_state(IdleState.new())


class JumpState:
	extends AirState
	
	var jump_extend_time := 0.0
	
	func enter(player: Node) -> void:
		print("enter state: JumpState")
		player.sprite.play("jump_hold")
		var jump_vector = (player.get_floor_normal().normalized()
							if player.is_on_floor() else
							Vector2.UP)
		var modifier = 1.0 if player.is_on_floor() else 0.7
		player.base_velocity += jump_vector * player.jump_force * modifier
		player.jump_count += 1
		player.can_fast_fall = true
		jump_extend_time = player.jump_extend_max_time

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if not Input.is_action_pressed("jump"):
			player.change_state(AirState.new())
		super.handle_input(player, input_dir)
		
	func physics_update(player: Node, delta: float) -> void:
		super.physics_update(player, delta)		
		
		if jump_extend_time > 0:
			jump_extend_time -= delta
			player.base_velocity.y -= (
				jump_extend_time / player.jump_extend_max_time
				 * player.speed * player.air_control_strength
				* delta)
		else:
			player.change_state(AirState.new())


class AttackState:
	extends PlayerState

	@export var state_name = "AttackState"
	
	var direction: Vector2
	var knockback: float
	var damage: int

	func _init(_dir: Vector2, _knockback: float, _damage: int) -> void:
		direction = _dir
		knockback = _knockback
		damage = _damage

	func enter(player: Node) -> void:
		player.sprite.play("neutral_attack")
		var attack = player.Attack.instantiate()
		attack.attacker = player
		attack.global_position = player.global_position + direction * 64
		attack.knockback = direction * knockback
		attack.damage = damage
		player.get_parent().add_child(attack)

	func update(player: Node, delta: float) -> void:
		if not player.sprite.is_playing():
			player.change_state(AirState.new())


class HitstunState:
	extends PlayerState

	@export var state_name = "HitstunState"
	
	var timer: float = 0.3

	func enter(player: Node) -> void:
		player.sprite.play("hitstun")

	func update(player: Node, delta: float) -> void:
		timer -= delta
		if timer <= 0:
			player.change_state(AirState.new())

	func physics_update(player: Node, delta: float) -> void:
		player.base_velocity.y += player.gravity * delta
		player.base_velocity.y = clamp(player.base_velocity.y, -INF, 1200)
