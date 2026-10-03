extends Entity
class_name Enemy

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func _physics_process(_delta: float) -> void:
	
	var player := get_tree().get_first_node_in_group("baseDungeonPlayer") as Node2D
	if player:
		velocity = global_position.direction_to(player.global_position) * speed
		
	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= _delta
		
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
		
	move_and_slide()

func knockbackEnemy(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration

func takeDamage(amount: int) -> void:
	super(amount)
	var player := get_tree().get_first_node_in_group("baseDungeonPlayer") as Node2D
	if player:
		var knockback_direction := (global_position - player.global_position).normalized()
		knockbackEnemy(knockback_direction, 150.0, 0.12)
