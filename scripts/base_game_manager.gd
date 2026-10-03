extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var dungeon_generation: Node = $dungeonGeneration/dungeonGenerationScript
@onready var room_tracker: RoomTracker = $roomTracker
@onready var camera: RoomCamera = $Camera2D


# Game/Level Startup
func _ready() -> void:
	room_tracker.room_entered.connect(_on_room_entered)
	start_level()
	
	SceneManager.returnBaseGame.connect(send_player_to_dream_sequence)
	send_player_to_dream_sequence()
	
	

func start_level():
	room_tracker.reset()
	dungeon_generation.generate_dungeon()
	place_player_in_start_room()
	camera.snap_to(room_tracker.room_center(dungeon_generation.start_room))

func place_player_in_start_room() -> void:
	var room = dungeon_generation.start_room.instance
	var half := DungeonBuilder.ROOM_TILES * DungeonBuilder.TILE_SIZE / 2.0
	player.global_position = room.global_position + Vector2(half, half)
	
	
func _on_room_entered(room: RoomData) -> void:
	print("Entered ", RoomData.Type.keys()[room.type], " at ", room.roomPos)
	camera.move_to(room_tracker.room_center(room))
	

	
	
	
var dreamSequences = ["res://scenes/dreamSequence/platformer1.tscn", "res://scenes/dreamSequence/platformer2.tscn", "res://scenes/dreamSequence/platformer3.tscn"]




func send_player_to_dream_sequence() -> void:
	
	var dreamSequenceIndex = randi_range(0, dreamSequences.size() - 1)
	var randomTime = randf_range(30.0, 60.0) #choose a random time from 30 to a minute
	print("Sleeping in " + str(randomTime) + " seconds....")
	
	await get_tree().create_timer(randomTime).timeout
	
	SceneManager.enter_dream_scene(dreamSequences[dreamSequenceIndex])
