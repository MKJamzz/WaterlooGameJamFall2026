class_name DungeonPreset
extends Resource

@export var display_name := "Floor 1"

@export_group("Layout")
@export var room_count := 10
@export_range(0.0, 1.0) var branch_chance := 0.5
@export_range(0.0, 1.0) var extra_door_chance := 0.25
@export_range(0.0, 1.0) var double_door_chance := 0.2

@export_group("Special rooms")
@export var bonus_room_count := 1
@export var enemy_room_count := 1

@export_group("Room scenes")
## Leave a pool empty to use the builder's default for that room type.
@export var start_rooms: Array[PackedScene] = []
@export var normal_rooms: Array[PackedScene] = []
@export var enemy_rooms: Array[PackedScene] = []
@export var exit_rooms: Array[PackedScene] = []
@export var bonus_rooms: Array[PackedScene] = []
