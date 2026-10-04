class_name DungeonBuilder
extends Node2D

@export_group("Room scenes")
@export var start_rooms: Array[PackedScene] = []
@export var normal_rooms: Array[PackedScene] = []
@export var enemy_rooms: Array[PackedScene] = []
@export var exit_rooms: Array[PackedScene] = []
@export var bonus_rooms: Array[PackedScene] = []

@export_group("Bridges")
## Bridge scenes are used as stamps: their tiles are copied over the rooms'
## tiles, replacing the walls, and then the bridge scene is discarded.
@export var bridge_horizontal: PackedScene
@export var bridge_vertical: PackedScene

@export_group("Background")
## A TileMapLayer OUTSIDE this node (clear() deletes this node's children).
@export var background: TileMapLayer
@export var void_source_id := 0
@export var void_tile := Vector2i(0, 0)
@export var background_margin_tiles := 30

const TILE_SIZE := 16
const ROOM_TILES := 25
## Tile index along a wall where each doorway is centred (0-24).
const DOOR_SLOTS := {1: [12], 2: [7, 17]}

var room_nodes := {}  # Vector2i grid cell -> Room


func build(rooms: Dictionary) -> void:
	clear()
	var stride := float(ROOM_TILES * TILE_SIZE)

	# Pass 1: place every room, touching its neighbours.
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
		room_nodes[pos] = room

	# Pass 2: every room exists now, so bridges can paint across both sides of a wall.
	for pos in rooms:
		_stamp_bridges(rooms[pos])

	_fill_background(rooms)


func clear() -> void:
	room_nodes.clear()
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
		RoomData.Type.ENEMY:
			pool = enemy_rooms

	if pool.is_empty():
		pool = normal_rooms
	if pool.is_empty():
		return null
	return pool.pick_random()


# --------------------------------------------------------------- BRIDGES

## Only right and bottom sides, so each shared wall is stamped once.
func _stamp_bridges(data: RoomData) -> void:
	var origin := data.roomPos * ROOM_TILES  # room's top-left, in dungeon tiles
	for slot in DOOR_SLOTS.get(data.doors["right"], []):
		_stamp(bridge_horizontal, origin + Vector2i(ROOM_TILES, slot))
	for slot in DOOR_SLOTS.get(data.doors["bottom"], []):
		_stamp(bridge_vertical, origin + Vector2i(slot, ROOM_TILES))


## Copies every TileMapLayer of the bridge scene into whichever room it lands
## in. `anchor` is where the bridge's tile (0, 0) goes, in dungeon tiles.
##
## Each bridge layer goes into the room's TileMapLayer with the same name
## (bridge "Trees" -> room "Trees"). For those name-matched layers the bridge
## owns its whole footprint: cells the bridge layer leaves empty are ERASED in
## the room layer, so walls under the doorway are removed.
## Bridge layers with no matching room layer fall back to the room's main
## `tiles` layer and only overwrite the cells they use.
func _stamp(scene: PackedScene, anchor: Vector2i) -> void:
	if scene == null:
		return
	var bridge := scene.instantiate()
	var layers := _find_tile_layers(bridge)
	if layers.is_empty():
		push_warning("Bridge scene has no TileMapLayer.")
		bridge.free()
		return

	# Footprint: every cell used by any layer of the bridge.
	var footprint := {}
	for source in layers:
		for cell in source.get_used_cells():
			footprint[cell] = true

	for source in layers:
		for cell in footprint:
			var world: Vector2i = anchor + cell
			var room_cell := Vector2i(
				floori(world.x / float(ROOM_TILES)),
				floori(world.y / float(ROOM_TILES))
			)
			var room := room_nodes.get(room_cell) as Room
			if room == null:
				continue
			var target := _target_layer(room, source.name)
			if target == null:
				continue
			var local: Vector2i = world - room_cell * ROOM_TILES
			var name_matched := target.name == source.name

			var bridge_src := source.get_cell_source_id(cell)
			if bridge_src == -1:
				# Empty in this bridge layer: clear the room's tile here, but only
				# in a name-matched layer (never wipe the fallback main layer).
				if name_matched:
					target.erase_cell(local)
				continue

			# The bridge and the room may use different TileSets, so translate
			# the source ID into the room's TileSet by matching textures.
			var src_id := _remap_source(source.tile_set, target.tile_set, bridge_src)
			if src_id == -1:
				continue
			target.set_cell(
				local,
				src_id,
				source.get_cell_atlas_coords(cell),
				source.get_cell_alternative_tile(cell)
			)
	_check_stamp(scene, anchor, layers)
	bridge.free()


## The room layer a bridge layer should be stamped into: a TileMapLayer
## child of the room with the same name, otherwise the room's main layer.
func _target_layer(room: Room, layer_name: StringName) -> TileMapLayer:
	var named := room.get_node_or_null(NodePath(String(layer_name))) as TileMapLayer
	if named:
		return named
	return room.tiles


## Returns the node itself (if it's a TileMapLayer) plus every direct child
## that is a TileMapLayer.
func _find_tile_layers(node: Node) -> Array[TileMapLayer]:
	var out: Array[TileMapLayer] = []
	if node is TileMapLayer:
		out.append(node)
	for child in node.get_children():
		if child is TileMapLayer:
			out.append(child)
	return out


## Finds the source in `dst` that uses the same texture as `source_id` in `src`.
## Returns -1 (and warns) if the room's TileSet doesn't have that atlas.
func _remap_source(src: TileSet, dst: TileSet, source_id: int) -> int:
	if src == null or dst == null:
		return -1
	if src == dst:
		return source_id

	var a := src.get_source(source_id) as TileSetAtlasSource
	if a == null or a.texture == null:
		return -1

	for i in dst.get_source_count():
		var id := dst.get_source_id(i)
		var b := dst.get_source(id) as TileSetAtlasSource
		if b and b.texture and b.texture.resource_path == a.texture.resource_path:
			return id

	push_warning("Room TileSet has no atlas for %s" % a.texture.resource_path)
	return -1


# ------------------------------------------------------------ BACKGROUND

## Paints void tiles under the whole dungeon so the area past the outer
## rooms matches the rooms' dark border.
func _fill_background(rooms: Dictionary) -> void:
	if background == null or rooms.is_empty():
		return
	background.clear()

	var min_cell: Vector2i = rooms.keys()[0]
	var max_cell: Vector2i = min_cell
	for pos in rooms:
		min_cell = Vector2i(mini(min_cell.x, pos.x), mini(min_cell.y, pos.y))
		max_cell = Vector2i(maxi(max_cell.x, pos.x), maxi(max_cell.y, pos.y))

	var margin := Vector2i.ONE * background_margin_tiles
	var from := min_cell * ROOM_TILES - margin
	var to := (max_cell + Vector2i.ONE) * ROOM_TILES + margin
	for x in range(from.x, to.x):
		for y in range(from.y, to.y):
			background.set_cell(Vector2i(x, y), void_source_id, void_tile)


## Swaps in the preset's room pools. Empty pools keep the current ones.
func apply_preset(preset: DungeonPreset) -> void:
	if not preset.start_rooms.is_empty():
		start_rooms = preset.start_rooms
	if not preset.normal_rooms.is_empty():
		normal_rooms = preset.normal_rooms
	if not preset.enemy_rooms.is_empty():
		enemy_rooms = preset.enemy_rooms
	if not preset.exit_rooms.is_empty():
		exit_rooms = preset.exit_rooms
	if not preset.bonus_rooms.is_empty():
		bonus_rooms = preset.bonus_rooms

# ------------------------------------------------------------ DEBUG

## After a bridge is stamped, finds any colliding tiles left in the
## bridge's walkable path (cells where the bridge itself has no collision).
func _check_stamp(scene: PackedScene, anchor: Vector2i, layers: Array[TileMapLayer]) -> void:
	# Walkable path = cells the bridge uses where none of its layers collide.
	var walkable := {}
	for source in layers:
		for cell in source.get_used_cells():
			walkable[cell] = true
	for source in layers:
		for cell in walkable.keys():
			if _has_collision(source, cell):
				walkable.erase(cell)

	var problems := {}  # room_cell -> Array of strings
	for cell in walkable:
		var world: Vector2i = anchor + cell
		var room_cell := Vector2i(
			floori(world.x / float(ROOM_TILES)),
			floori(world.y / float(ROOM_TILES))
		)
		var node: Node = room_nodes.get(room_cell)
		if node == null:
			problems.get_or_add(room_cell, []).append("no room in this cell (bridge leads nowhere)")
			continue
		if not node is Room:
			problems.get_or_add(room_cell, []).append("root isn't a Room, so the bridge was skipped")
			continue

		var local: Vector2i = world - room_cell * ROOM_TILES
		# Recursive: catches layers nested deeper than direct children too.
		for layer in node.find_children("*", "TileMapLayer", true, false):
			if _has_collision(layer, local):
				problems.get_or_add(room_cell, []).append(
					"layer '%s' blocks %s (path: %s)" % [layer.name, local, node.get_path_to(layer)]
				)

	for room_cell in problems:
		var node: Node = room_nodes.get(room_cell)
		var file: String = node.scene_file_path if node else "-"
		var msgs: Array = problems[room_cell]
		push_warning("BLOCKED DOORWAY  bridge=%s  room=%s  scene=%s" % [
			scene.resource_path.get_file(), room_cell, file
		])
		# Dedupe so a wide wall doesn't spam 20 lines per layer.
		var seen := {}
		for m in msgs:
			if not seen.has(m):
				seen[m] = true
				print("    ", m)


func _has_collision(layer: TileMapLayer, cell: Vector2i) -> bool:
	if layer.tile_set == null:
		return false
	var td := layer.get_cell_tile_data(cell)
	if td == null:
		return false
	for p in layer.tile_set.get_physics_layers_count():
		if td.get_collision_polygons_count(p) > 0:
			return true
	return false
