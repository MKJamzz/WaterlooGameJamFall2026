extends Node

signal returnBaseGame

var savedScene: Node = null #store progress of scene in base game

func enter_dream_scene(path: String) -> void:
	var tree := get_tree() # get tree of scenes being shown
	savedScene = tree.current_scene
	tree.root.remove_child(savedScene) # safe to remove the current scene for base game since we have it saved in variable that we can reference
	var dreamGame: Node = load(path).instantiate()
	tree.root.add_child(dreamGame)
	tree.current_scene = dreamGame # add dreamGame to top of tree
	
func return_to_base_game() -> void:
	var tree := get_tree()
	tree.current_scene.queue_free()
	tree.root.add_child(savedScene)
	tree.current_scene = savedScene
	savedScene = null
	returnBaseGame.emit()
