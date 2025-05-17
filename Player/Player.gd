extends CharacterBody2D

@export var speed := 200.0
@export var jump_force := -300.0
@export var gravity := 400.0
@export var max_jumps := 5

@onready var sprite = $AnimatedSprite2D
var jump_count := 0

func _physics_process(delta):
	handle_input()
	apply_physics(delta)
	move_and_slide()
	check_grounded()
	update_animation()

func handle_input():
	velocity.x = 0

	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
		sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		velocity.x = speed
		sprite.flip_h = false

	if Input.is_action_just_pressed("jump") and jump_count < max_jumps:
		velocity.y = jump_force
		jump_count += 1

func apply_physics(delta):
	velocity.y += gravity * delta

func check_grounded():
	if is_on_floor():
		jump_count = 0

func update_animation():
	if not is_on_floor():
		if sprite.animation != "jump":
			sprite.play("jump")
	elif velocity.x != 0:
		if sprite.animation != "walk":
			sprite.play("walk")
	else:
		if sprite.animation != "idle":
			sprite.play("idle")
