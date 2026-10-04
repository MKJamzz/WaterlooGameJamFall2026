extends CanvasLayer
class_name RunEndScreen
## Attach to the root `RunEndScreen` (CanvasLayer) of run_end_screen.tscn.
## Death: red flash -> zoom on the knight -> message -> results.
## Win:   straight to the same results panel, no death penalty.

@export var death_message := "Your mind drifts beyond no return"
@export var zoom_amount := 3.0        # how much closer the camera gets
@export var zoom_time := 1.2
@export var message_hold_time := 1.8  # how long the message stays up

@export var count_time := 0.6        # seconds each stat takes to roll up
@export var total_count_time := 1.5  # the total rolls slower for drama
@export var line_pause := 0.15       # gap between lines

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
	title_label.text = "You Escaped" if won else "Run Over"
	stats_label.text = ""
	total_label.text = ""
	continue_button.disabled = true

	results.modulate.a = 0.0
	results.show()
	var fade := create_tween()
	fade.tween_property(results, "modulate:a", 1.0, 0.4)
	await fade.finished

	# [label, count, points each]
	var rows := [
		["Coins", s.currency, 5],
		["Enemies killed", s.enemiesKilled, 30],
		["Times drifted", s.timesDrifted, 20],
	]
	var lines := []  # finished lines stay on screen while the next one rolls

	for row in rows:
		await _roll(row[1], count_time, func(v: int) -> void:
			stats_label.text = "\n".join(lines + [_row_text(row[0], v, row[2])]))
		lines.append(_row_text(row[0], row[1], row[2]))
		await get_tree().create_timer(line_pause, true).timeout

	lines.append("Floors cleared:   x%d" % s.floorsCleared)
	stats_label.text = "\n".join(lines)
	await get_tree().create_timer(line_pause * 2, true).timeout

	if not won:
		lines.append("Death penalty:    x%.1f" % RunDataState.DEATH_MULTIPLIER)
		stats_label.text = "\n".join(lines)
		await get_tree().create_timer(line_pause * 2, true).timeout

	await _roll(s.calculateScore(won), total_count_time, func(v: int) -> void:
		total_label.text = "Total Score: %d" % v)

	# little gold flash when the total lands
	var pop := create_tween()
	pop.tween_property(total_label, "modulate", Color.GOLD, 0.08)
	pop.tween_property(total_label, "modulate", Color.WHITE, 0.4)

	continue_button.disabled = false
	continue_button.grab_focus()


## Counts from 0 to target, fast at first and slowing down as it lands.
func _roll(target: int, duration: float, update: Callable) -> void:
	if target <= 0:
		update.call(0)
		return
	var t := create_tween()
	t.tween_method(func(v: float) -> void: update.call(int(v)), 0.0, float(target), duration) \
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	await t.finished
	update.call(target)  # make sure it ends on the exact number


func _row_text(label: String, count: int, points: int) -> String:
	return "%-16s %d  x%d  = %d" % [label + ":", count, points, count * points]


func _on_continue_pressed() -> void:
	RunDataState.resetRunStats()
	get_tree().paused = false
	# Swap this for your scene_manager / main menu when you have one.
	get_tree().reload_current_scene()
