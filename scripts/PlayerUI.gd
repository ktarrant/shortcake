extends Node2D

const Player = preload("res://scripts/Player.gd")

@export var player: Player = null
@onready var container := $Control
@onready var icon := $Control/MarginContainer/TextureRect
@onready var damage_label := $Control/MarginContainer/TextureRect/Label

func _ready():
	init_for_player(player.player_id)
	
	update_display()
	
func init_for_player(player_id: int):
	# Anchor to bottom
	container.anchor_left = 0.5
	container.anchor_right = 0.5
	container.anchor_top = 1.0
	container.anchor_bottom = 1.0
	
	# Center the pivot and apply offsets based on ID
	var offset_x := 0
	match player_id:
		0:
			offset_x = -800
		1:
			offset_x = -300
		2:
			offset_x = 300
		3:
			offset_x = 800
	
	container.offset_left = offset_x - 64
	container.offset_right = offset_x + 64
	container.offset_top = -120
	container.offset_bottom = -20
	
func _process(_delta):
	if player:
		update_display()

func update_display():
	damage_label.text = str(round(player.percent)) + "%"
	
	# Optional: change color as damage increases
	if player.percent > 100:
		damage_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # red
	elif player.percent > 50:
		damage_label.add_theme_color_override("font_color", Color(1, 1, 0.2))  # yellow
	else:
		damage_label.add_theme_color_override("font_color", Color(1, 1, 1))  # white
