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
	pass
	
func update_animation(player: Node) -> void:
	pass


class IdleState:
	extends PlayerState
	
	@export var state_name = "IdleState"

	func enter(player: Node) -> void:
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
		# rotate sprite to floor
		var normal = player.get_floor_normal()
		player.sprite.rotation = atan2(normal.x, -normal.y)


class RunState:
	extends PlayerState

	@export var state_name = "RunState"
	
	func enter(player: Node) -> void:
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
		var current_speed: float = player.speed * input_strength if run else player.speed * input_strength * player.walk_speed_fraction
		var slowdown := 0.7 if player.overlapping_player_count > 0 else 1.0
		var floor_normal = player.get_floor_normal()
		var floor_direction = Vector2(-floor_normal.y, floor_normal.x)
		# Apply a small rotation to help smooth movement up slopes
		if input_dir.x > 0:
			floor_direction = floor_direction.rotated(player.slope_walk_angle)
		else:
			floor_direction = (-floor_direction).rotated(-player.slope_walk_angle)
		player.input_velocity = floor_direction * current_speed * slowdown

	func physics_update(player: Node, delta: float) -> void:
		pass

	func update_animation(player: Node) -> void:
		var input_strength: float = abs(player.get_movement_input().x)
		if input_strength > player.run_threshold:
			player.sprite.play("run")
		else:
			player.sprite.play("walk")
		player.sprite.speed_scale = clamp(abs(player.velocity.x) / player.speed, 0.5, 1.5)
		# rotate sprite to floor
		var normal = player.get_floor_normal()
		player.sprite.rotation = atan2(normal.x, -normal.y)


class JumpState:
	extends PlayerState

	@export var state_name = "JumpState"
	
	func enter(player: Node) -> void:
		player.sprite.play("jump_hold")
		var jump_vector = player.get_floor_normal().normalized() if player.is_on_floor() else Vector2.UP
		player.base_velocity += jump_vector * player.jump_force
		player.jump_count += 1
		player.can_fast_fall = true
		player.jump_cut_applied = false

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if player.is_on_floor():
			player.change_state(IdleState.new())

	func physics_update(player: Node, delta: float) -> void:
		player.base_velocity.y += player.gravity * delta
		player.base_velocity.y = clamp(player.base_velocity.y, -INF, 1200)


class FallState:
	extends PlayerState

	@export var state_name = "FallState"
	
	func enter(player: Node) -> void:
		player.sprite.play("jump_release")

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if player.is_on_floor():
			player.change_state(IdleState.new())

	func physics_update(player: Node, delta: float) -> void:
		player.base_velocity.y += player.gravity * delta
		player.base_velocity.y = clamp(player.base_velocity.y, -INF, 1200)


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
			player.change_state(FallState.new())


class HitstunState:
	extends PlayerState

	@export var state_name = "HitstunState"
	
	var timer: float = 0.3

	func enter(player: Node) -> void:
		player.sprite.play("hitstun")

	func update(player: Node, delta: float) -> void:
		timer -= delta
		if timer <= 0:
			player.change_state(FallState.new())

	func physics_update(player: Node, delta: float) -> void:
		player.base_velocity.y += player.gravity * delta
		player.base_velocity.y = clamp(player.base_velocity.y, -INF, 1200)
