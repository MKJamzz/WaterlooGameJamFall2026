extends Node

## Emitted once each time the player crosses into a different room.
signal room_entered(room: RoomData)

var player: CharacterBody2D = null
var generator: Node = null
var current_room: RoomData = null


func _ready() -> void:
	set_physics_process(false)  # idle until a dungeon calls setup()


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(generator) or generator.rooms.is_empty():
		return

	var room: RoomData = room_at(player.global_position)
	if room != null and room != current_room:
		current_room = room
		room_entered.emit(room)


## Call after a new floor is generated. Hooks up the new scene's nodes and
## clears the old room so the start room counts as "entered".
func setup(new_generator: Node, new_player: CharacterBody2D) -> void:
	generator = new_generator
	player = new_player
	reset()
	set_physics_process(true)


func reset() -> void:
	current_room = null


## Call when leaving the dungeon entirely (e.g. back to a menu or a dream minigame).
func clear() -> void:
	set_physics_process(false)
	generator = null
	player = null
	current_room = null


## Which room a world position is in, or null. Enemies use this on spawn.
func room_at(world_pos: Vector2) -> RoomData:
	return generator.rooms.get(world_to_cell(world_pos))


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
