extends CanvasLayer

@onready var fade: ColorRect = $ColorRect


func _ready() -> void:
	fade.modulate.a = 0.0
	fade.hide()


func fade_in(duration := 0.4) -> void:
	fade.show()
	await create_tween().tween_property(fade, "modulate:a", 1.0, duration).finished


func fade_out(duration := 0.4) -> void:
	await create_tween().tween_property(fade, "modulate:a", 0.0, duration).finished
	fade.hide()
