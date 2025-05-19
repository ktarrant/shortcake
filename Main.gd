extends Node2D

class_name Main
const Player = preload("res://Player/Player.gd")

@onready var spawn_point = $SpawnPoint
@onready var player = $Player
@onready var death_zone = $DeathZone

func _on_DeathZone_body_entered(body):
	if body is Player:
		body.respawn(spawn_point.global_position)
