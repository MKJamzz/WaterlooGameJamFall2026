class_name DungeonBuilder
extends Node

@export_group("Room scenes")
@export var start_rooms: Array[PackedScene] = []
@export var normal_rooms: Array[PackedScene] = []
@export var exit_rooms: Array[PackedScene] = []
@export var bonus_rooms: Array[PackedScene] = []

@export_group("Bridges")
@export var bridge_horizontal: PackedScene
@export var bridge_vertical: PackedScene
## Gap between rooms, in tiles. Your bridge scenes should be this long.
@export var bridge_length_tiles := 4

const TILE_SIZE := 16
const ROOM_TILES := 25
## Tile index along a wall where each doorway is centred (0-24).
## One door uses the middle; two doors use the A and B slots.
const DOOR_SLOTS := {1: [12], 2: [7, 17]}


func build(rooms: Dictionary) -> void:
	clear()
	var stride := float((ROOM_TILES + bridge_length_tiles) * TILE_SIZE)

	for pos in rooms:
		var data: RoomData = rooms[pos]
		var scene := _pick_scene(data.type)
		if scene == null:
			push_warning("No scene available for room type %s" % RoomData.Type.keys()[data.type])
			continue

		var room: Node2D = scene.instantiate()
		room.position = Vector2(pos) * stride
		add_child(room)
		data.instance = room

		if room.has_method("setup_doors"):
			room.setup_doors(data.doors)
		_place_bridges(data, room.position)


func clear() -> void:
	for child in get_children():
		child.queue_free()


## Random scene from the pool for this type. Falls back to normal rooms
## if you haven't made any for that type yet.
func _pick_scene(type: RoomData.Type) -> PackedScene:
	var pool: Array[PackedScene] = normal_rooms
	match type:
		RoomData.Type.START:
			pool = start_rooms
		RoomData.Type.EXIT:
			pool = exit_rooms
		RoomData.Type.BONUS:
			pool = bonus_rooms

	if pool.is_empty():
		pool = normal_rooms
	if pool.is_empty():
		return null
	return pool.pick_random()


## Only right and bottom sides, so each shared wall gets its bridges once.
func _place_bridges(data: RoomData, room_pos: Vector2) -> void:
	var room_px := float(ROOM_TILES * TILE_SIZE)

	if bridge_horizontal:
		for slot in DOOR_SLOTS.get(data.doors["right"], []):
			var bridge: Node2D = bridge_horizontal.instantiate()
			bridge.position = room_pos + Vector2(room_px, slot * TILE_SIZE)
			add_child(bridge)

	if bridge_vertical:
		for slot in DOOR_SLOTS.get(data.doors["bottom"], []):
			var bridge: Node2D = bridge_vertical.instantiate()
			bridge.position = room_pos + Vector2(slot * TILE_SIZE, room_px)
			add_child(bridge)
