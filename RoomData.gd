extends Node
class_name RoomData

enum Type {START, NORMAL, EXIT, BONUS, ENEMY}

var type := Type.NORMAL
var roomPos : Vector2i
var roomCleared := false
var doors := {"top": 0, "bottom": 0, "left": 0, "right": 0}
var instance : Node2D = null

func _init(pos: Vector2i, room_type: Type = Type.NORMAL) -> void:
	roomPos = pos
	type = room_type
