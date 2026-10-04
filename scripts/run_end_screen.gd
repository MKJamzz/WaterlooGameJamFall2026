extends CanvasLayer
class_name RunEndScreen
## Attach to the root `RunEndScreen` (CanvasLayer) of run_end_screen.tscn.
## Death: red flash -> zoom on the knight -> message -> results.
## Win:   straight to the same results panel, no death penalty.

@export var death_message := "Your mind drifts beyond no return"
@export var zoom_amount := 3.0        # how much closer the camera gets
@export var zoom_time := 1.2
@export var message_hold_time := 1.8  # how long the message stays up

@onready var flash: ColorRect = $FlashRed
@onready var message: Label = $Message
@onready var results: Control = $Results
@onready var title_label: Label = $Results/PanelContainer/VBoxContainer/Title
@onready var stats_label: Label = $Results/PanelContainer/VBoxContainer/Stats
@onready var total_label: Label = $Results/PanelContainer/VBoxContainer/Total
@onready var continue_button: BaseButton = $Results/PanelContainer/VBoxContainer2/Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # runs while the game is paused
	layer = 10                               # draw above the HUD
	flash.modulate.a = 0.0
	message.modulate.a = 0.0
	message.text = death_message
	results.hide()
	add_to_group("run_end_screen")
	continue_button.pressed.connect(_on_continue_pressed)


func play_death(player: Node2D, camera: Camera2D) -> void:
	get_tree().paused = true  # freeze enemies, projectiles, etc.

	# The HUD is parented to the camera, so it would zoom with it. Hide it.
	for child in camera.get_children():
		if child is CanvasItem:
			child.hide()

	# Tweens made with create_tween() follow this node's process mode,
	# so they keep running while the tree is paused.
	var t := create_tween()

	# 1. Red flash
	t.tween_property(flash, "modulate:a", 0.75, 0.08)
	t.tween_property(flash, "modulate:a", 0.0, 0.5)

	# 2. Zoom in on the knight (position and zoom at the same time)
	t.tween_property(camera, "global_position", player.global_position, zoom_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(camera, "zoom", camera.zoom * zoom_amount, zoom_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# 3. Message fades in, holds, fades out
	t.tween_property(message, "modulate:a", 1.0, 0.6)
	t.tween_interval(message_hold_time)
	t.tween_property(message, "modulate:a", 0.0, 0.4)

	await t.finished
	show_results(false)


func play_win() -> void:
	get_tree().paused = true
	show_results(true)


func show_results(won: bool) -> void:
	var s := RunDataState
	var multiplier := 1.0 if won else RunDataState.DEATH_MULTIPLIER

	title_label.text = "You Escaped" if won else "Run Over"
	stats_label.text = "\n".join([
		"Coins: %d  x5   = %d" % [s.currency, s.currency * 5],
		"Enemies killed: %d  x30 = %d" % [s.enemiesKilled, s.enemiesKilled * 30],
		"Times drifted: %d  x20 = %d" % [s.timesDrifted, s.timesDrifted * 20],
		"Floors cleared: x%d" % s.floorsCleared,
		"" if won else "Death penalty:    x%.1f" % multiplier,
	])
	total_label.text = "Total Score: %d" % s.calculateScore(won)

	results.modulate.a = 0.0
	results.show()
	create_tween().tween_property(results, "modulate:a", 1.0, 0.5)
	continue_button.grab_focus()


func _on_continue_pressed() -> void:
	RunDataState.resetRunStats()
	get_tree().paused = false
	# Swap this for your scene_manager / main menu when you have one.
	get_tree().reload_current_scene()
