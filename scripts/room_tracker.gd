class_name RoomTracker
extends Node

## Emitted once each time the player crosses into a different room.
signal room_entered(room: RoomData)

@onready var player: CharacterBody2D = %Player
@onready var generator: Node = $"../dungeonGeneration/dungeonGenerationScript"

var current_room: RoomData = null


func _physics_process(_delta: float) -> void:
	if player == null or generator == null or generator.rooms.is_empty():
		return

	var room: RoomData = generator.rooms.get(world_to_cell(player.global_position))
	if room != null and room != current_room:
		current_room = room
		room_entered.emit(room)


## Call when a new floor is generated so the start room counts as "entered".
func reset() -> void:
	current_room = null


## Which grid cell of the layout a world position falls in.
func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local := world_pos - _dungeon_origin()
	return Vector2i(floori(local.x / _room_px()), floori(local.y / _room_px()))


## World-space centre of a room, e.g. for the camera to move to.
func room_center(room: RoomData) -> Vector2:
	return _dungeon_origin() + (Vector2(room.roomPos) + Vector2(0.5, 0.5)) * _room_px()


func _room_px() -> float:
	return float(DungeonBuilder.ROOM_TILES * DungeonBuilder.TILE_SIZE)


func _dungeon_origin() -> Vector2:
	return generator.builder.global_position if generator.builder else Vector2.ZERO
