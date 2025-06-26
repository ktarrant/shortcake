extends Control

var ready_players := {}
var joystick_ids := []

func _ready():
	joystick_ids = Input.get_connected_joypads()
	for id in joystick_ids:
		ready_players[id] = false

func _process(delta):
	for id in joystick_ids:
		if Input.is_joy_button_pressed(id, JOY_BUTTON_START) and not ready_players[id]:
			ready_players[id] = true
			print("Player %d ready" % id)

	if ready_players.size() > 0 and ready_players.values().all(func(v): return v):
		start_game()

func start_game():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
