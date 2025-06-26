extends Control

func _ready():
	$HBoxContainer/VBoxContainer/NewGame.pressed.connect(_on_new_game_pressed)
	$HBoxContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/PlayerSelect.tscn")

func _on_quit_pressed():
	get_tree().quit()
