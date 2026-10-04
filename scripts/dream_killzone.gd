extends Area2D

@onready var timer: Timer = $Timer
@onready var spawn_point: Marker2D = $"../SpawnPoint"
@onready var dream_player: Node2D = $"../DreamPlayer/CharacterBody2D"


func _on_body_entered(body: Node2D) -> void:
	dream_player.global_position = spawn_point.global_position
	
