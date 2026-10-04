extends Node2D

@onready var interactable: Area2D = $interactable
@onready var store_popup = $CanvasLayer/dungeonStorePopup


func _ready() -> void:
	interactable.interact = _on_interact
	store_popup.closed.connect(_on_store_closed)


func _on_interact():
	interactable.set_deferred("monitoring", false)  # no re-triggering while open
	store_popup.open()


func _on_store_closed():
	interactable.set_deferred("monitoring", true)  # can open it again later
