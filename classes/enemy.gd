extends Entity
class_name Enemy

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("baseDungeonPlayer") as Node2D
	if player:
		velocity = global_position.direction_to(player.global_position) * speed
		move_and_slide()
