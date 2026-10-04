extends Area2D

@onready var teleport_sound: AudioStreamPlayer2D = $TeleportSound


func _on_body_entered(body: Node):
	teleport_sound.play()
	await get_tree().create_timer(0.7).timeout
	SceneManager.return_to_base_game.call_deferred()
	
