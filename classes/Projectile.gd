extends Area2D
class_name Projectile

@export var speed: float = 200.0
@export var projectileLifeTime: float = 3.0
var damage := 20

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var tween := create_tween()
	tween.tween_interval(projectileLifeTime)
	tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	# Moves straight in the local X direction of the node
	position += transform.x * speed * delta

func _on_body_entered(body:Node) -> void:
	
	if body is Player:
		body.takeDamage(damage)
		
		
	queue_free()
