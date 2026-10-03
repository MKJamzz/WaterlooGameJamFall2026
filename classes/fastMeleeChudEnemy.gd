extends Enemy
class_name FastMeleeChudEnemy

@export var wait_time := 2.0


func _ready() -> void:
	super() #so entity _ready method isn't overwritten
	max_health = 20
	current_health = max_health
	speed = 150.0
	damage = 10
	

	
func meleeAttack() -> void: 
	
	for body in $AttackRange.get_overlapping_bodies():
		if body is Player and body != self:
			body.takeDamage(damage)
			print(body.current_health)
			
	await get_tree().create_timer(wait_time).timeout

			
			

func _on_attack_range_body_entered(body: Node2D) -> void:
	speed = 0.0
	await meleeAttack()
	speed = 150.0
