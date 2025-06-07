extends Control

@export var player: Node = null

func _ready():
	update_display()

func _process(_delta):
	if player:
		update_display()

func update_display():
	var damage_label = $MarginContainer/HBoxContainer/Label
	damage_label.text = str(round(player.damage)) + "%"
	
	# Optional: change color as damage increases
	if player.damage > 100:
		damage_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))  # red
	elif player.damage > 50:
		damage_label.add_theme_color_override("font_color", Color(1, 1, 0.2))  # yellow
	else:
		damage_label.add_theme_color_override("font_color", Color(1, 1, 1))  # white
