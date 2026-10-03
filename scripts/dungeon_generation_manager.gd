class_name DungeonGenerator
extends Node

@export var room_count := 10
## Chance each room branches during a pass (one room is always forced if none do).
@export_range(0.0, 1.0) var branch_chance := 0.5
## Chance an adjacent pair that isn't already connected gets a bonus door.
@export_range(0.0, 1.0) var extra_door_chance := 0.25
## Chance a wall with a door gets two doorways instead of one.
@export_range(0.0, 1.0) var double_door_chance := 0.2
## Drag your DungeonBuilder node here so the layout gets built in the scene.
@export var builder: DungeonBuilder
@export var bonus_room_count := 1
@export var enemy_room_count := 0


const DIRS := {
	"top": Vector2i.UP,
	"bottom": Vector2i.DOWN,
	"left": Vector2i.LEFT,
	"right": Vector2i.RIGHT,
}
const OPPOSITE := {"top": "bottom", "bottom": "top", "left": "right", "right": "left"}

var rooms := {}  # Vector2i -> RoomData
var start_room: RoomData
var exit_room: RoomData


## Copies a preset's settings onto this generator and its builder.
func apply_preset(preset: DungeonPreset) -> void:
	room_count = preset.room_count
	branch_chance = preset.branch_chance
	extra_door_chance = preset.extra_door_chance
	double_door_chance = preset.double_door_chance
	bonus_room_count = preset.bonus_room_count
	enemy_room_count = preset.enemy_room_count
	if builder:
		builder.apply_preset(preset)


func generate_dungeon(preset: DungeonPreset = null) -> void:
	if preset:
		apply_preset(preset)
	generate_layout()
	place_doors()
	select_exit_room()
	for i in bonus_room_count:
		place_special_room(RoomData.Type.BONUS)
	for i in enemy_room_count:
		place_special_room(RoomData.Type.ENEMY)
	print_layout()
	if builder:
		builder.build(rooms)


func clear_dungeon() -> void:
	rooms.clear()
	start_room = null
	exit_room = null
	if builder:
		builder.clear()


# ---------------------------------------------------------------- LAYOUT

func generate_layout() -> void:
	rooms.clear()

	# START sits at (0, 0), the middle of an unbounded grid.
	start_room = RoomData.new(Vector2i.ZERO, RoomData.Type.START)
	rooms[start_room.roomPos] = start_room
	if room_count <= 1:
		return

	# START always makes the first branch.
	_branch_from(start_room)

	while rooms.size() < room_count:
		var branched := false
		# Snapshot: rooms created during this pass wait until the next one.
		var current_rooms := rooms.values()
		current_rooms.shuffle()

		# Every room gets a chance to branch, or not.
		for room in current_rooms:
			if rooms.size() >= room_count:
				break
			if randf() < branch_chance and _branch_from(room):
				branched = true

		# Failsafe: if nobody branched this pass, force one room to.
		if not branched and rooms.size() < room_count:
			for room in current_rooms:
				if _branch_from(room):
					break


## Adds one NORMAL room on a random free side. Returns false if all sides are taken.
func _branch_from(room: RoomData) -> bool:
	var free_dirs := []
	for side in DIRS:
		if not rooms.has(room.roomPos + DIRS[side]):
			free_dirs.append(side)
	if free_dirs.is_empty():
		return false

	var new_pos: Vector2i = room.roomPos + DIRS[free_dirs.pick_random()]
	rooms[new_pos] = RoomData.new(new_pos, RoomData.Type.NORMAL)
	return true


# ----------------------------------------------------------------- DOORS

func place_doors() -> void:
	for room in rooms.values():
		for side in room.doors:
			room.doors[side] = 0

	# 1) Guarantee: grow a random tree of doors out from START until every
	#    room is reachable. START doesn't have to connect to all its neighbours.
	var connected := {start_room.roomPos: true}
	var candidates := _unconnected_edges(start_room.roomPos, connected)

	while connected.size() < rooms.size():
		if candidates.is_empty():
			push_error("Layout has a room that can't be reached.")
			return
		var edge: Dictionary = candidates.pop_at(randi() % candidates.size())
		var target: Vector2i = edge.from + DIRS[edge.side]
		if connected.has(target):
			continue  # already reached by another door
		_add_door(edge.from, edge.side)
		connected[target] = true
		candidates.append_array(_unconnected_edges(target, connected))

	# 2) Bonus: random extra doors between adjacent rooms.
	for pos in rooms:
		for side in ["right", "bottom"]:  # checks each adjacent pair only once
			var other: Vector2i = pos + DIRS[side]
			if rooms.has(other) and rooms[pos].doors[side] == 0 \
					and randf() < extra_door_chance:
				_add_door(pos, side)


## Sides of `pos` that lead to an existing room not yet connected.
func _unconnected_edges(pos: Vector2i, connected: Dictionary) -> Array:
	var edges := []
	for side in DIRS:
		var neighbour: Vector2i = pos + DIRS[side]
		if rooms.has(neighbour) and not connected.has(neighbour):
			edges.append({"from": pos, "side": side})
	return edges


## Sets 1 or 2 doors on the shared wall, on both rooms so they always agree.
func _add_door(pos: Vector2i, side: String) -> void:
	var value := 2 if randf() < double_door_chance else 1
	rooms[pos].doors[side] = value
	rooms[pos + DIRS[side]].doors[OPPOSITE[side]] = value


# ------------------------------------------------------------------ EXIT

func select_exit_room() -> RoomData:
	var dist := _distances_from(start_room.roomPos)
	var max_dist := -1
	var furthest := []

	for pos in dist:
		if pos == start_room.roomPos:
			continue
		if dist[pos] > max_dist:
			max_dist = dist[pos]
			furthest = [pos]
		elif dist[pos] == max_dist:
			furthest.append(pos)

	if furthest.is_empty():
		return null
	exit_room = rooms[furthest.pick_random()]  # random draw on ties
	exit_room.type = RoomData.Type.EXIT
	return exit_room


## Number of doors you walk through to reach each room from `from_pos`.
func _distances_from(from_pos: Vector2i) -> Dictionary:
	var dist := {from_pos: 0}
	var queue := [from_pos]
	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		var room: RoomData = rooms[pos]
		for side in room.doors:
			if room.doors[side] > 0:
				var next: Vector2i = pos + DIRS[side]
				if not dist.has(next):
					dist[next] = dist[pos] + 1
					queue.append(next)
	return dist


# --------------------------------------------------------------- SPECIAL

## Turns a random NORMAL room into `room_type`. Call once per special room.
func place_special_room(room_type: RoomData.Type) -> RoomData:
	var options := rooms.values().filter(
		func(r: RoomData) -> bool: return r.type == RoomData.Type.NORMAL
	)
	if options.is_empty():
		push_warning("No NORMAL rooms left to turn into a special room.")
		return null
	var room: RoomData = options.pick_random()
	room.type = room_type
	return room


# ----------------------------------------------------------------- DEBUG

## Prints the layout to the Output panel. Rooms show as [S] start, [E] exit,
## [B] bonus, [ ] normal. Doors: - or = between columns (1 or 2),
## | or | | between rows (1 or 2).
func print_layout() -> void:
	if rooms.is_empty():
		return

	var min_p: Vector2i = rooms.keys()[0]
	var max_p: Vector2i = min_p
	for pos in rooms:
		min_p = Vector2i(mini(min_p.x, pos.x), mini(min_p.y, pos.y))
		max_p = Vector2i(maxi(max_p.x, pos.x), maxi(max_p.y, pos.y))

	#const H_DOOR := [" ", "-", "="]
	#const V_DOOR := ["   ", " | ", "| |"]

	#print("--- Dungeon: %d rooms ---" % rooms.size())
	#for y in range(min_p.y, max_p.y + 1):
		#var row := ""
		#var below := ""
		#for x in range(min_p.x, max_p.x + 1):
			#var pos := Vector2i(x, y)
			#if rooms.has(pos):
				#var room: RoomData = rooms[pos]
				#row += "[%s]" % _room_letter(room) + H_DOOR[room.doors["right"]]
				#below += V_DOOR[room.doors["bottom"]] + " "
			#else:
				#row += "    "
				#below += "    "
		#print(row)
		#if y < max_p.y:
			#print(below)


func _room_letter(room: RoomData) -> String:
	if room.type == RoomData.Type.NORMAL:
		return " "
	# First letter of the enum name, so new types show up automatically.
	return RoomData.Type.keys()[room.type][0]
	
