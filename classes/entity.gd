
extends CharacterBody2D
class_name Entity

signal health_changed(current: int, max: int)
signal died # signal is how you can setup the ability to call methods/functions in this class from other files

@export var max_health := 100
var current_health: int
@export var speed := 100
@export var damage := 1

@export var sprite: CanvasItem
@export var flash_time := 0.3

var flash_tween: Tween

func flash_red() -> void:
	var target: CanvasItem = sprite if sprite else self
	if flash_tween:
		flash_tween.kill()       # restart the flash if hit again mid-flash
	target.modulate = Color.RED
	flash_tween = create_tween()
	flash_tween.tween_property(target, "modulate", Color.WHITE, flash_time)

func _ready() -> void:
	current_health = max_health

func takeDamage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	flash_red()
	
	if current_health == 0:
		die()

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	
func die() -> void:
	died.emit() # emit is how you call that signal
	queue_free()
