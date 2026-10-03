extends Node2D

var weapon_damage : float = 100.0
@onready var anim_slash: AnimationPlayer = $Sprite2D/AnimationPlayer


func _ready() -> void:
	look_at(get_global_mouse_position())
	anim_slash.play("sword_slash")
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sword_slash":
		queue_free()



func _on_area_2d_body_entered(body: Node2D) -> void:
	body.takeDamage(weapon_damage)
	print("ENEMY HIT" + str(body.current_health))
	pass # Replace with function body.
