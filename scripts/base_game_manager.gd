extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var dungeon_generation: Node = $dungeonGeneration/dungeonGenerationScript
@onready var camera: RoomCamera = $Camera2D
@onready var label: Label = $Camera2D/Label
@onready var fade: CanvasLayer = $Camera2D/Fade


# Game/Level Startup
func _ready() -> void:
	RoomTracker.room_entered.connect(_on_room_entered)
	start_level()

	SceneManager.returnBaseGame.connect(send_player_to_dream_sequence)
	send_player_to_dream_sequence()
	
	label.visible = false #initally hide label
	


func start_level():
	dungeon_generation.generate_dungeon()
	RoomTracker.setup(dungeon_generation, player)  # also resets current_room
	place_player_in_start_room()
	camera.snap_to(RoomTracker.room_center(dungeon_generation.start_room))


func place_player_in_start_room() -> void:
	var room = dungeon_generation.start_room.instance
	var half := DungeonBuilder.ROOM_TILES * DungeonBuilder.TILE_SIZE / 2.0
	player.global_position = room.global_position + Vector2(half, half)


func _on_room_entered(room: RoomData) -> void:
	print("Entered ", RoomData.Type.keys()[room.type], " at ", room.roomPos)
	camera.move_to(RoomTracker.room_center(room))

func reset_stats() -> void:
	label.visible = false
	fade.fade(0, 0)
	

var dreamSequences = ["res://scenes/dreamSequence/platformer1.tscn", "res://scenes/dreamSequence/platformer2.tscn", "res://scenes/dreamSequence/platformer3.tscn", "res://scenes/dreamSequence/platformer4.tscn", "res://scenes/dreamSequence/platformer5.tscn", "res://scenes/dreamSequence/platformer6.tscn"]

var dreamTextSayings = ["Your eyes start to feel heavy...", "You feel yourself drifting off...", "You feel the urge to close your eyes..."]


func send_player_to_dream_sequence() -> void:
	
	var regularPlayerSpeed = player.speed

	reset_stats()
	
	var dreamSequenceIndex = randi_range(0, dreamSequences.size() - 1)
	var randomTime = randf_range(10, 12) #choose a random time from 30 to a minute
	print("Sleeping in " + str(randomTime) + " seconds....")

	await get_tree().create_timer(randomTime - 5.0).timeout
	var dreamTextSayingsIndex = randi_range(0, dreamTextSayings.size() - 1)
	label.visible = true
	label.text = dreamTextSayings[dreamTextSayingsIndex]
	player.speed = 30

	fade.fade(1.0, 5.0)

	await get_tree().create_timer(5.0).timeout
	
	player.speed = regularPlayerSpeed
	
	SceneManager.enter_dream_scene(dreamSequences[dreamSequenceIndex])
