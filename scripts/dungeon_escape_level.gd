extends Node2D

@onready var interactable: Area2D = $interactable
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact
	
func _on_interact():
	print("Imm a chudddd")
