extends Control

const MAX_PLAYERS := 4
const INPUT_OPTIONS := ["Keyboard"]

@onready var player_rows := [
	$VBox/PlayerRow1,
	$VBox/PlayerRow2,
	$VBox/PlayerRow3,
	$VBox/PlayerRow4,
]

var assigned_inputs := ["Keyboard"]
var connected_joypads := []

func _ready():
	$BottomButtons/BackButton.pressed.connect(_on_BackButton_pressed)
	$BottomButtons/StartGameButton.pressed.connect(_on_StartGameButton_pressed)
	
	connected_joypads = Input.get_connected_joypads()
	for joypad in connected_joypads:
		var label = "JoyCon %d" % joypad
		if label not in INPUT_OPTIONS:
			INPUT_OPTIONS.append(label)

	# Initialize Player 1 row
	setup_player_row(player_rows[0], "Keyboard", 0, true)

	# Clear other rows
	for i in range(1, MAX_PLAYERS):
		clear_player_row(player_rows[i])

	update_add_dummy_button()

func setup_player_row(row, input_label: String, index: int, is_player1 := false, is_dummy := false):
	row.get_node("AddDummyButton").visible = false
	row.get_node("InputComboBox").disabled = is_dummy
	row.get_node("RemoveButton").disabled = is_player1

	# Set player label
	row.get_node("PlayerLabel").text = "Player %d" % (index + 1)

	var combo: OptionButton = row.get_node("InputComboBox")
	combo.clear()
	for option in INPUT_OPTIONS:
		if option not in assigned_inputs or option == input_label:
			combo.add_item(option)

	for i in combo.item_count:
		if combo.get_item_text(i) == input_label:
			combo.select(i)
			break

	var callable = Callable(self, "_on_input_changed").bind(row)
	if not combo.is_connected("item_selected", callable):
		combo.connect("item_selected", callable)

	var remove_button = row.get_node("RemoveButton")
	var remove_callable = Callable(self, "_on_remove_pressed").bind(row)
	if not remove_button.is_connected("pressed", remove_callable):
		remove_button.connect("pressed", remove_callable)

	row.visible = true
	if input_label != "Dummy":
		assigned_inputs.append(input_label)

func clear_player_row(row):
	row.visible = false
	row.get_node("InputComboBox").clear()
	row.get_node("AddDummyButton").visible = false

func update_add_dummy_button():
	for i in range(1, MAX_PLAYERS):
		var row = player_rows[i]
		if not row.visible:
			row.visible = true
			row.get_node("AddDummyButton").visible = true
			var dummy_button = row.get_node("AddDummyButton")
			var callable = Callable(self, "_on_add_dummy_pressed").bind(row)
			if not dummy_button.is_connected("pressed", callable):
				dummy_button.connect("pressed", callable)
			break

func _on_add_dummy_pressed(row):
	var index = player_rows.find(row)
	setup_player_row(row, "Dummy", index, false, true)
	update_add_dummy_button()

func _on_remove_pressed(row):
	var combo: OptionButton = row.get_node("InputComboBox")
	var selected_input := combo.get_item_text(combo.selected)
	assigned_inputs.erase(selected_input)
	clear_player_row(row)
	update_add_dummy_button()

func _on_input_changed(index, row):
	var combo: OptionButton = row.get_node("InputComboBox")
	var selected_input := combo.get_item_text(index)
	for input in assigned_inputs:
		if input == selected_input:
			return
	assigned_inputs.append(selected_input)

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		var device_id: int = event.device
		var label := "JoyCon %d" % device_id
		if label in assigned_inputs:
			return
		for i in range(1, MAX_PLAYERS):
			var row = player_rows[i]
			if not row.visible:
				setup_player_row(row, label, i)
				update_add_dummy_button()
				break

func _on_BackButton_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/MainMenu.tscn")

func _on_StartGameButton_pressed():
	get_tree().change_scene_to_file("res://scenes/main/Main.tscn")
