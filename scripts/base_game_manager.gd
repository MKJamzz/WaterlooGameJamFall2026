extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var dungeon_generation: Node = $dungeonGeneration/dungeonGenerationScript
@onready var room_tracker: RoomTracker = $roomTracker
@onready var camera: RoomCamera = $Camera2D

# Game/Level Startup
func _ready() -> void:
	room_tracker.room_entered.connect(_on_room_entered)
	start_level()

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
