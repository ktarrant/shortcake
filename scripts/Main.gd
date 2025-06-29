extends Node2D

class_name Main

const Player = preload("res://scripts/Player.gd")
const PlayerUI = preload("res://scripts/PlayerUI.gd")

@onready var spawn_point = $SpawnPoint
@onready var death_zone = $DeathZone
@onready var all_players: Array[Player] = [
	$Player1, $Player2, $Player3, $Player4
]
@onready var all_player_uis: Array[PlayerUI] = [
	$CanvasLayer/HBoxContainer/PlayerUI1, 
	$CanvasLayer/HBoxContainer/PlayerUI2, 
	$CanvasLayer/HBoxContainer/PlayerUI3,
	$CanvasLayer/HBoxContainer/PlayerUI4
]
var active_players: Array[Player] = []

func _ready():
	for player_data in Global.player_configs:
		var player := all_players[player_data["index"]]
		var player_ui := all_player_uis[player_data["index"]]
		print("Spawning player: ", player, player_data)
		if player_data["state"] == Global.PlayerSelectState.DISABLED:
			player.queue_free()
			player_ui.queue_free()
			continue
		player.visible = true
		player_ui.visible = true
		if player_data["state"] == Global.PlayerSelectState.DUMMY:
			player.is_dummy = true
		else:
			player.is_dummy = false
			player.player_input = player_data["input_type"]
			player.player_joycon_id = player_data["joycon_id"]
		active_players.append(player)

	$Camera2D.players = active_players

func _on_DeathZone_body_entered(body):
	if body is Player:
		body.respawn(spawn_point.global_position)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_tree().quit()
