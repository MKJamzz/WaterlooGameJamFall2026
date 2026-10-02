extends Area2D



func _on_body_entered(body: Node):
	SceneManager.return_to_base_game.call_deferred()
