extends Node2D

@onready var spawn_point = $SpawnPoint
@onready var player = $Player
@onready var death_zone = $DeathZone

func _ready():
	# Ensure player starts at the spawn point
	respawn_player(player)

func _on_DeathZone_body_entered(body):
	if body == player:
		respawn_player(player)

func respawn_player(player_node):
	player_node.velocity = Vector2.ZERO
	player_node.global_position = spawn_point.global_position
