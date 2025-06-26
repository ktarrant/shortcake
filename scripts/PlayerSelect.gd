extends Control

var player_joypads := {1: null, 2: null, 3: null, 4: null}
var dummy_count := 0

func _ready():
	update_display()
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/AddDummyButton.pressed.connect(_on_add_dummy_pressed)

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		var new_id = event.device
		for i in range(2, 5):  # player 2 to 4
			if player_joypads[i] == null and not new_id in player_joypads.values():
				player_joypads[i] = new_id
				update_display()
				break

func update_display():
	for i in range(1, 5):
		var label = get_node("VBoxContainer/PlayerRow%d" % i)
		if i == 1:
			label.text = "Player 1: Keyboard & Mouse"
		elif typeof(player_joypads[i]) == TYPE_INT:
			label.text = "Player %d: JoyCon %d" % [i, player_joypads[i]]
		elif player_joypads[i] == "Dummy":
			label.text = "Player %d: Dummy" % i
		else:
			label.text = "Player %d: Not Connected" % i

func _on_add_dummy_pressed():
	for i in range(2, 5):
		if player_joypads[i] == null:
			player_joypads[i] = "Dummy"
			update_display()
			break

func _on_start_pressed():
	var connected_players = player_joypads.values().filter(func(p): return p != null)
	if connected_players.size() >= 1:
		get_tree().change_scene_to_file("res://path_to_your_game_scene.tscn")
