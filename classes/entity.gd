
extends CharacterBody2D
class_name Entity

signal health_changed(current: int, max: int)
signal died # signal is how you can setup the ability to call methods/functions in this class from other files

@export var max_health := 100
var current_health: int
@export var speed := 100.0
@export var damage := 1

func _ready() -> void:
	current_health = max_health

func takeDamage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	
func die() -> void:
	died.emit() # emit is how you call that signal
	queue_free()
