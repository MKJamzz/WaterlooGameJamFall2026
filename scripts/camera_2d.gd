class_name RoomCamera
extends Camera2D

@export var tween_time := 0.35
@export var transition: Tween.TransitionType = Tween.TRANS_CUBIC
@export var ease_type: Tween.EaseType = Tween.EASE_OUT
## Zoom so one room fills the screen's height. Non-integer zoom can make
## pixel art look uneven, so leave this off if you'd rather set zoom by hand.
@export var fit_room_height := false

var _tween: Tween


func _ready() -> void:
	if fit_room_height:
		var room_px := float(DungeonBuilder.ROOM_TILES * DungeonBuilder.TILE_SIZE)
		zoom = Vector2.ONE * (get_viewport_rect().size.y / room_px)


## Slide to a position. Interrupts any slide already in progress.
func move_to(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_trans(transition).set_ease(ease_type)
	_tween.tween_property(self, "global_position", target, tween_time)


## Jump instantly, e.g. at the start of a floor.
func snap_to(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	global_position = target
	reset_smoothing()
