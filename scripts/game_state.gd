extends Node
signal next_level_requested

var run: DungeonRun = preload("res://data/runs/main_run.tres")
var level_index := 0


func current_preset() -> DungeonPreset:
	return run.levels[level_index]

func has_next_level() -> bool:
	return level_index + 1 < run.levels.size()

func advance() -> void:
	level_index += 1

func reset_run() -> void:
	level_index = 0
