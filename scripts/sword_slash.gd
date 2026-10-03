extends Node2D

var weapon_damage : float = 100.0
@onready var anim_slash: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var slash_area: Area2D = $Area2D
@onready var slash_shape: CollisionShape2D = $Area2D/CollisionShape2D


func _ready() -> void:
	look_at(get_global_mouse_position())
	anim_slash.play("sword_slash")
	slash()


func slash() -> void:
	# Wait for the animation to enable the hitbox (give up after ~1 second just in case)
	var frames := 0
	while slash_shape.disabled and frames < 60:
		await get_tree().physics_frame
		frames += 1
	# One more frame so the area can register what it now overlaps
	await get_tree().physics_frame

	var enemies := slash_area.get_overlapping_bodies().filter(func(b): return b is Enemy)

	var origin := global_position
	enemies.sort_custom(func(a, b):
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))

	var count := mini(int(RunDataState.attackEnemiesPerAtk), enemies.size())
	for i in count:
		if is_instance_valid(enemies[i]):
			enemies[i].takeDamage(weapon_damage)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sword_slash":
		queue_free()
