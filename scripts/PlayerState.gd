extends Node
class_name PlayerState


var attack_data := {
	"neutral_attack": {
		"animation": "neutral_attack",
		"direction_func": func(player):
			var n = player.get_floor_normal()
			var dir = Vector2(-n.y, n.x).normalized()
			return -dir if player.sprite.flip_h else dir,
		"knockback": 200,
		"damage": 10
	},
	"air_neutral_attack": {
		"animation": "air_neutral_attack",
		"direction_func": func(player): return (
			Vector2(-1, 0)
			if player.sprite.flip_h
			else Vector2(1, 0)
		),
		"knockback": 150,
		"damage": 6
	},
	"air_up_attack": {
		"animation": "air_up_attack",
		"direction_func": func(player): return Vector2(0, -1),
		"knockback": 180,
		"damage": 8
	},
	"air_down_attack": {
		"animation": "air_down_attack",
		"direction_func": func(player): return Vector2(0, 1),
		"knockback": 220,
		"damage": 12
	}
}


func enter(player: Node) -> void:
	pass

func exit() -> void:
	pass

func handle_input(player: Node, input_dir: Vector2) -> void:
	pass

func update(player: Node, delta: float) -> void:
	player.shield_health = min(player.shield_health + player.shield_regen_rate * delta, player.max_shield_health)

func physics_update(player: Node, delta: float) -> void:
	pass

func update_animation(player: Node) -> void:		# rotate sprite to floor
	# sprite rotation
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
		elif Input.is_action_just_pressed("attack"):
			player.change_state(AttackState.new("neutral_attack", player))
		elif Input.is_action_pressed("shield") and player.shield_health > player.min_shield_activation:
			player.change_state(ShieldState.new())
		elif input_dir.y < -0.7 and player.get_floor_normal().y < -0.7 and not player.dropped_through_platform:
			player.set_collision_mask_value(player.one_way_platform_layer, false)
			player.dropped_through_platform = true
		else:
			player.input_velocity = Vector2.ZERO
			
	func update_animation(player: Node) -> void:
		player.sprite.play("idle")
		player.sprite.speed_scale = 1.0
		
	func physics_update(player: Node, delta: float) -> void:
		# Auto-transition to fall if not grounded
		if not player.is_on_floor():
			player.change_state(AirState.new())


class RunState:
	extends PlayerState

	var state_name = "RunState"
	
	func enter(player: Node) -> void:
		print("enter state: RunState")
		player.sprite.play("run")
		player.input_velocity = Vector2.ZERO

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if Input.is_action_just_pressed("jump"):
			player.change_state(JumpState.new())
		elif Input.is_action_just_pressed("attack"):
			player.change_state(AttackState.new("neutral_attack", player))
		elif Input.is_action_pressed("shield") and player.shield_health > player.min_shield_activation:
			player.change_state(ShieldState.new())
		elif input_dir.y < -0.7 and player.get_floor_normal().y < -0.7 and not player.dropped_through_platform:
			player.set_collision_mask_value(player.one_way_platform_layer, false)
			player.dropped_through_platform = true
		elif input_dir.x == 0:
			player.change_state(IdleState.new())
		elif input_dir.x < 0:
			player.sprite.flip_h = true
		elif input_dir.x > 0:
			player.sprite.flip_h = false
		if player.state is not RunState:
			return
		
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
		super.update_animation(player)
		var input_strength: float = abs(player.get_movement_input().x)
		if input_strength > player.run_threshold:
			player.sprite.play("run")
		else:
			player.sprite.play("walk")
		player.sprite.speed_scale = clamp(abs(player.velocity.x) / player.speed, 0.5, 1.5)

	func physics_update(player: Node, delta: float) -> void:
		super.physics_update(player, delta)


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
		elif Input.is_action_just_pressed("attack"):
			var key := ""
			if input_dir.y > 0.5:
				key = "air_up_attack"
			elif input_dir.y < -0.5:
				key = "air_down_attack"
			else:
				key = "air_neutral_attack"
			player.change_state(AttackState.new(key, player))
		elif input_dir.y < -0.7 and not player.in_fast_fall:
			player.base_velocity.y += player.fast_fall_burst
			player.in_fast_fall = true
		if player.state is not AirState:
			return

		var slowdown := 0.7 if player.overlapping_player_count > 0 else 1.0
		if input_dir.x != 0:
			player.input_velocity.x = lerp(player.input_velocity.x,
										  input_dir.x * player.speed * slowdown,
										  player.air_control_strength)
		else:
			player.input_velocity.x = lerp(player.input_velocity.x, 0.0, 0.1)

	func physics_update(player: Node, delta: float) -> void:
		if player.is_on_floor():
			player.land()
			player.input_velocity = Vector2.ZERO
			if player.get_movement_input().x != 0:
				player.change_state(RunState.new())
			else:
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
		player.in_fast_fall = false
		jump_extend_time = player.jump_extend_max_time

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if not Input.is_action_pressed("jump"):
			player.change_state(AirState.new())
		super.handle_input(player, input_dir)
	
	func physics_update(player: Node, delta: float) -> void:
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
	
	var direction: Vector2
	var knockback: float
	var damage: int

	func _init(_attack: String, _player: Player) -> void:
		print("enter state: AttackState")
		var data = attack_data[_attack]
		_player.sprite.play(data["animation"])
		direction = data["direction_func"].call(_player)
		knockback = data["knockback"]
		damage = data["damage"]

	func enter(player: Node) -> void:
		var attack = player.Attack.instantiate()
		attack.attacker = player
		attack.global_position = player.global_position + direction * 64
		attack.knockback = direction * knockback
		attack.damage = damage
		player.get_parent().add_child(attack)

	func update(player: Node, delta: float) -> void:
		super.update(player, delta)
		if not player.sprite.is_playing():
			if player.is_on_floor():
				if player.get_movement_input().x != 0:
					player.change_state(RunState.new())
				else:
					player.change_state(IdleState.new())
			else:
				player.change_state(AirState.new())


class HitstunState:
	extends PlayerState
	
	var timer: float = 0.3

	func enter(player: Node) -> void:
		player.sprite.play("hitstun")
		player.input_velocity = Vector2.ZERO

	func update(player: Node, delta: float) -> void:
		super.update(player, delta)
		timer -= delta
		if timer <= 0:
			player.change_state(AirState.new())


class ShieldState:
	extends PlayerState

	func enter(player: Node) -> void:
		print("enter state: ShieldState")
		player.sprite.play("shield")
		player.input_velocity = Vector2.ZERO

	func handle_input(player: Node, input_dir: Vector2) -> void:
		if not Input.is_action_pressed("shield"):
			player.sprite.modulate = player.character_tint
			player.change_state(IdleState.new())
		elif input_dir.x != 0:
			player.sprite.flip_h = input_dir.x < 0

	func update(player: Node, delta: float) -> void:
		player.shield_health = max(player.shield_health - player.shield_drain_rate * delta, 0.0)
		if player.shield_health <= 0.0:
			player.sprite.modulate = player.character_tint
			player.change_state(IdleState.new())

	func physics_update(player: Node, delta: float) -> void:
		# Auto-transition to fall if not grounded
		if not player.is_on_floor():
			player.change_state(AirState.new())
			
	func update_animation(player: Node) -> void:
		super.update_animation(player)
		var health_ratio: float = player.shield_health / player.max_shield_health
		var tint_strength: float = 1.0 - lerp(0.4, 1.0, health_ratio)  # darker when shield is low
		player.sprite.modulate = player.character_tint.darkened(tint_strength)

	func apply_damage(player: Node, amount: int, knockback: Vector2) -> void:
		if player.shield_health > 0.0:
			player.shield_health -= amount
			player.base_velocity += knockback * player.reduced_knockback_factor
			if player.shield_health <= 0.0:
				player.sprite.modulate = player.character_tint
				player.change_state(HitstunState.new())
		else:
			player.apply_damage(amount, knockback)
