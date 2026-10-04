extends Enemy
class_name BomberChudEnemy

@export var wait_time := 2.0
@onready var timer: Timer = $Timer
@onready var explosion_sound_effect: AudioStreamPlayer2D = $ExplosionSoundEffect


func _ready() -> void:
	super() #so entity _ready method isn't overwritten
	speed = 100
	damage = 30
	

	
func explode() -> void: 
	speed = 0
	await get_tree().create_timer(wait_time).timeout
	
	for body in $ExplosionArea.get_overlapping_bodies():
		if body is Player and body != self:
			body.takeDamage(damage)
			
	scale = Vector2(0.2, 0.2)
	$AnimatedSprite2D.play("explosion")
	explosion_sound_effect.play()
	
	
	timer.start()
	await timer.timeout
	queue_free()

func die() -> void:
	super()
	explode()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		explode.call_deferred()
	
	
