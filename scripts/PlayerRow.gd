extends HBoxContainer

var index: int = -1
var state: Global.PlayerSelectState = Global.PlayerSelectState.DISABLED
var current_input_type: String = ""
var current_joycon_id: int = 0
var input_options: Array[String] = []

func _ready():
	$AddDummyButton.pressed.connect(_on_AddDummyButton_pressed)
	$RemoveButton.pressed.connect(_on_RemoveButton_pressed)
	
func init(new_state: Global.PlayerSelectState, new_index: int, input_type: String = "", joycon_id: int = 0):
	index = new_index
	current_input_type = input_type
	current_joycon_id = joycon_id
	get_node("PlayerLabel").text = "Player %d" % (index + 1)
	set_state(new_state)

func set_state(new_state: Global.PlayerSelectState):
	state = new_state
	match state:
		Global.PlayerSelectState.DISABLED:
			get_node("InputComboBox").clear()
			get_node("AddDummyButton").visible = (index != 0)
			get_node("RemoveButton").visible = false

		Global.PlayerSelectState.LOCAL:
			var combo: OptionButton = get_node("InputComboBox")
			combo.disabled = false
			get_node("RemoveButton").disabled = (index == 0)
			get_node("AddDummyButton").visible = false
			get_node("RemoveButton").visible = true

		Global.PlayerSelectState.DUMMY:
			var combo: OptionButton = get_node("InputComboBox")
			combo.disabled = true
			combo.clear()
			combo.add_item("Dummy")
			combo.select(0)
			get_node("RemoveButton").visible = true
			get_node("AddDummyButton").visible = false

func get_state() -> Global.PlayerSelectState:
	return state

func get_input_type() -> String:
	return current_input_type
	
func set_input_type(input_type: String, joycon_id: int):
	current_input_type = input_type
	current_joycon_id = joycon_id

func update_input_options(new_options: Array[String]):
	input_options = new_options
	
	if state == Global.PlayerSelectState.LOCAL:
		var option_button: OptionButton = get_node("InputComboBox")
		
		option_button.clear()
		
		var new_index := 0
		if current_input_type not in new_options:
			option_button.add_item(current_input_type)
		else:
			new_index = new_options.find(current_input_type)
		
		for option in new_options:
			option_button.add_item(option)
		
		option_button.select(new_index)
	
func _on_AddDummyButton_pressed():
	set_state(Global.PlayerSelectState.DUMMY)

func _on_RemoveButton_pressed():
	set_state(Global.PlayerSelectState.DISABLED)
