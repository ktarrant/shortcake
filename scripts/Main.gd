extends Node2D

class_name Main

const Player = preload("res://scripts/Player.gd")

@onready var spawn_point = $SpawnPoint
@onready var death_zone = $DeathZone


func _ready():
	$Camera2D.players = [$Player1, $Player2, $Player3, $Player4]

func _on_DeathZone_body_entered(body):
	if body is Player:
		body.respawn(spawn_point.global_position)
