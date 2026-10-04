extends CanvasLayer

const BASE_GAME := "res://scenes/baseGame/base_game.tscn"

@onready var start_button: Button = $TextureRect/Button

var starting := false


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	start_button.grab_focus()  # lets Enter/Space start it too


func _on_start_pressed() -> void:
	if starting:
		return
	starting = true

	GameState.reset_run()

	var tree := get_tree()  # grab it while we're still in the tree
	await LoadingScreen.fade_in()
	tree.change_scene_to_file(BASE_GAME)
	await tree.process_frame
	LoadingScreen.fade_out()
