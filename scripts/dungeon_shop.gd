extends Node2D

@onready var interactable: Area2D = $interactable

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	set_deferred("monitoring", false)  # only trigger once
	RunDataState.floorsCleared += 1
	GameState.next_level_requested.emit()
