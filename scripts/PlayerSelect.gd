
extends Control
class_name PlayerSelect

@export var player_row_scene: PackedScene
var max_players := 4

var input_options := []
var selected_inputs := []
var player_rows := []

func _ready():
	input_options = ["Mouse+Keyboard"] + _get_connected_joypads()
	selected_inputs = ["Mouse+Keyboard"]
	_create_player_rows()

func _get_connected_joypads() -> Array:
	var pads = []
	for i in range(Input.get_connected_joypads().size()):
		pads.append("JoyCon %d" % i)
	return pads

func _create_player_rows():
	var container = $PlayerRows
	for i in range(max_players):
		var row = container.get_node("PlayerRow%d" % i)
		var label = row.get_node("Label")
		var option_button = row.get_node("OptionButton")
		var remove_button = row.get_node("RemoveButton")

		label.text = "Player %d" % (i + 1)
		remove_button.disabled = (i == 0)
		remove_button.connect("pressed", Callable(self, "_on_remove_player_pressed").bind(i))
		option_button.clear()

		var available = _get_available_input_options(i)
		for input in available:
			option_button.add_item(input)
		option_button.select(0 if i == 0 else -1)
		option_button.connect("item_selected", Callable(self, "_on_input_selected").bind(i))

		player_rows.append({
			"label": label,
			"option_button": option_button,
			"remove_button": remove_button
		})

func _get_available_input_options(index: int) -> Array:
	var options = input_options.duplicate()
	for i in range(len(player_rows)):
		if i != index:
			var selected = player_rows[i]["option_button"].get_item_text(
				player_rows[i]["option_button"].get_selected()
			)
			options.erase(selected)
	return options

func _on_remove_player_pressed(index: int):
	if index == 0:
		return # never remove player 1
	for child in $PlayerRows.get_children():
		child.queue_free()
	player_rows.clear()
	selected_inputs = selected_inputs.slice(0, index) + selected_inputs.slice(index + 1)
	_create_player_rows()

func _on_input_selected(index: int, id: int):
	var option_button = player_rows[index]["option_button"]
	var selected = option_button.get_item_text(id)
	selected_inputs[index] = selected
	# Refresh all rows to update option availability
	for i in range(len(player_rows)):
		if i != index:
			var current = player_rows[i]["option_button"].get_item_text(
				player_rows[i]["option_button"].get_selected()
			)
			player_rows[i]["option_button"].clear()
			var options = _get_available_input_options(i)
			for opt in options:
				player_rows[i]["option_button"].add_item(opt)
			var current_index = options.find(current)
			if current_index != -1:
				player_rows[i]["option_button"].select(current_index)
