extends Node2D

@export var damage := 5
@export var knockback := Vector2.ZERO
@export var duration := 0.2

@onready var shape := $Area2D/CollisionShape2D.shape as Shape2D

func _draw():
	if shape is CircleShape2D:
		draw_circle(Vector2.ZERO, shape.radius, Color.RED)
	elif shape is RectangleShape2D:
		draw_rect(Rect2(-shape.extents, shape.extents * 2), Color.RED)
		
func _process(delta):
	queue_redraw()  # correct Godot 4 method
	
func _ready():
	set_deferred("monitoring", true)
	await get_tree().create_timer(duration).timeout
	queue_free()

func _on_body_entered(body):
	if body is Player and body != owner:
		body.apply_damage(damage, knockback)
