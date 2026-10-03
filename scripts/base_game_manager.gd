extends Node2D

@onready var player: CharacterBody2D = %Player
@onready var dungeon_generation: DungeonGenerator = $dungeonGeneration/dungeonGenerationScript
@onready var camera: RoomCamera = $Camera2D
@onready var label: Label = $Camera2D/Label
@onready var return_saying_label: Label = $Camera2D/ReturnSayingLabel
@onready var fade: CanvasLayer = $Camera2D/Fade

var transitioning := false
var justReturnedFromDream := false
var justReturnedFromNightmare := false


# Game/Level Startup
func _ready() -> void:
	RoomTracker.room_entered.connect(_on_room_entered)
	GameState.next_level_requested.connect(go_to_next_level)
	start_level()

	SceneManager.returnBaseGame.connect(send_player_to_dream_sequence)
	send_player_to_dream_sequence()
	RunDataState.resetRunStats()
	
	label.visible = false #initally hide label
	
	


func start_level() -> void:
	RoomTracker.clear()
	dungeon_generation.clear_dungeon()
	await get_tree().process_frame  # let the old rooms free before building new ones

	dungeon_generation.generate_dungeon(GameState.current_preset())
	RoomTracker.setup(dungeon_generation, player)  # also resets current_room
	place_player_in_start_room()
	camera.snap_to(RoomTracker.room_center(dungeon_generation.start_room))


func go_to_next_level() -> void:
	if transitioning:
		return
	if not GameState.has_next_level():
		print("Run complete!")
		return

	transitioning = true
	player.set_physics_process(false)
	await LoadingScreen.fade_in()

	GameState.advance()
	await start_level()

	player.set_physics_process(true)
	await LoadingScreen.fade_out()
	transitioning = false


func place_player_in_start_room() -> void:
	var room = dungeon_generation.start_room.instance
	var half := DungeonBuilder.ROOM_TILES * DungeonBuilder.TILE_SIZE / 2.0
	player.global_position = room.global_position + Vector2(half, half)


func _on_room_entered(room: RoomData) -> void:
	print("Entered ", RoomData.Type.keys()[room.type], " at ", room.roomPos)
	camera.move_to(RoomTracker.room_center(room))

func reset_stats() -> void:
	label.visible = false
	return_saying_label.visible = false
	fade.fade(0, 0)
	justReturnedFromDream = false
	justReturnedFromNightmare = false
	

var dreamSequences = ["res://scenes/dreamSequence/platformer1.tscn", "res://scenes/dreamSequence/platformer2.tscn", "res://scenes/dreamSequence/platformer3.tscn", "res://scenes/dreamSequence/platformer4.tscn", "res://scenes/dreamSequence/platformer5.tscn", "res://scenes/dreamSequence/platformer6.tscn"]
var dreamSequencesValueMap = {
	"res://scenes/dreamSequence/platformer1.tscn" : "nightmare",
	"res://scenes/dreamSequence/platformer2.tscn" : "dream",
	"res://scenes/dreamSequence/platformer3.tscn" : "dream",
	"res://scenes/dreamSequence/platformer4.tscn" : "dream",
	"res://scenes/dreamSequence/platformer5.tscn" : "nightmare",
	"res://scenes/dreamSequence/platformer6.tscn" : "nightmare"	
}


var sleepTextSayings = ["Your eyes start to feel heavy...", "You feel yourself drifting off...", "You feel the urge to close your eyes..."]

var dreamBuffStatSaying = ""
var dreamTextDreamBuffs = [ "increaseMaxHealth", "heal", "increaseSpeed", "increaseDamage"]
var dreamTextReturnSayings = ["You feel refreshed ", "Energy flows through your veins ", "You feel alert "]

func chooseDreamBuff() -> void:
	
	var dreamTextReturnSayingsIndex = randi_range(0, dreamTextReturnSayings.size() - 1)
	var dreamBuff = randi_range(0, dreamTextDreamBuffs.size() - 1)
	var chosenDreamBuff = dreamTextDreamBuffs[dreamBuff]
	
	if chosenDreamBuff == "increaseMaxHealth":
		player.changeMaxHealth(20)
		dreamBuffStatSaying = "+20 max health"
	
	elif chosenDreamBuff == "heal":
		player.heal(30)
		dreamBuffStatSaying = "+30 health"
		
	elif chosenDreamBuff == "increaseSpeed":
		player.changeSpeed(10)
		dreamBuffStatSaying = "+10 speed"
		
	elif chosenDreamBuff == "increaseDamage":
		player.changeDamage(20)
		dreamBuffStatSaying = "+20 damage"
		
	return_saying_label.text = dreamTextReturnSayings[dreamTextReturnSayingsIndex] + dreamBuffStatSaying
	return_saying_label.visible = true
	await get_tree().create_timer(5.0).timeout
	return_saying_label.visible = false
	
	
	



func send_player_to_dream_sequence() -> void:
	
	var regularPlayerSpeed = player.speed
	
	var applySleepEffect := justReturnedFromDream or justReturnedFromNightmare

	reset_stats()
	
	if applySleepEffect:
		chooseDreamBuff()
	
	var dreamSequenceIndex = randi_range(0, dreamSequences.size() - 1)
	var randomTime = randf_range(20, 30) #choose a random time from 30 to a minute
	print("Sleeping in " + str(randomTime) + " seconds....")

	await get_tree().create_timer(randomTime - 5.0).timeout
	var sleepTextSayingsIndex = randi_range(0, sleepTextSayings.size() - 1)
	label.visible = true
	label.text = sleepTextSayings[sleepTextSayingsIndex]
	player.speed = 30

	fade.fade(1.0, 5.0)

	await get_tree().create_timer(5.0).timeout
	
	player.speed = regularPlayerSpeed

	RunDataState.timesDrifted += 1
	
	var dreamSequencesValue = dreamSequences[dreamSequenceIndex]
	justReturnedFromDream = dreamSequencesValueMap[dreamSequencesValue] == "dream"
	
	SceneManager.enter_dream_scene(dreamSequencesValue)
