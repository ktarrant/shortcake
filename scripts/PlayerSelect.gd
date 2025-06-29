extends Control

const MAX_PLAYERS := 4

const PlayerRow = preload("res://scripts/PlayerRow.gd")

@onready var player_rows: Array[PlayerRow] = [
	$VBox/PlayerRow1,
	$VBox/PlayerRow2,
	$VBox/PlayerRow3,
	$VBox/PlayerRow4,
]

var available_inputs: Dictionary[String, int] = {}

func _ready():
	$BottomButtons/BackButton.pressed.connect(_on_BackButton_pressed)
	$BottomButtons/StartGameButton.pressed.connect(_on_StartGameButton_pressed)

	# Initialize Player 1 row with LOCAL
	player_rows[0].init(player_rows[0].State.LOCAL, 0, "Keyboard")

	# Initialize other rows with DISABLED
	for i in range(1, MAX_PLAYERS):
		player_rows[i].init(player_rows[i].State.DISABLED, i)

	update_input_options()
	
func update_available_inputs():
	var all_inputs = {"Keyboard": 0}
	for joypad in Input.get_connected_joypads():
		all_inputs["JoyCon %d" % joypad] = joypad
	var taken_inputs: Array[String] = []
	for row in player_rows:
		print(row.get_state(), row.get_input_type())
		if row.get_state() == PlayerRow.State.LOCAL:
			taken_inputs.append(row.get_input_type())
	print("All: ", all_inputs)
	print("Taken: ", taken_inputs)
	available_inputs.clear()
	for input in all_inputs:
		if input not in taken_inputs:
			available_inputs[input] = all_inputs[input]
	
func update_input_options():
	update_available_inputs()
	print("Available inputs: ", available_inputs)
	for row in player_rows:
		if row.state == PlayerRow.State.LOCAL:
			var input_list: Array[String]
			input_list.append(row.get_input_type())
			input_list.append_array(available_inputs.keys())
			row.update_input_options(input_list)

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		var device_id: int = event.device
		var label := "JoyCon %d" % device_id
		if label in available_inputs:
			return
		for i in range(1, MAX_PLAYERS):
			if player_rows[i].state == player_rows[i].State.DISABLED:
				player_rows[i].set_state(player_rows[i].State.LOCAL)
				player_rows[i].set_input_type(label, device_id)
				update_input_options()
				break

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_StartGameButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
