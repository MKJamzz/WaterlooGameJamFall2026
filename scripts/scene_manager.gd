extends Node

signal returnBaseGame

var savedScene: Node = null #store progress of scene in base game
var baseResolution: Vector2i

func enter_dream_scene(path: String) -> void:
	var tree := get_tree() # get tree of scenes being shown
	savedScene = tree.current_scene
	tree.root.remove_child(savedScene) # safe to remove the current scene for base game since we have it saved in variable that we can reference
	var dreamGame: Node = load(path).instantiate()
	tree.root.add_child(dreamGame)
	tree.current_scene = dreamGame # add dreamGame to top of tree
	
	baseResolution = get_window().content_scale_size
	get_window().content_scale_size = Vector2i(1152, 648)
	
func return_to_base_game() -> void:
	var tree := get_tree()
	tree.current_scene.queue_free()
	tree.root.add_child(savedScene)
	tree.current_scene = savedScene
	savedScene = null
	returnBaseGame.emit()
	
	get_window().content_scale_size = baseResolution
