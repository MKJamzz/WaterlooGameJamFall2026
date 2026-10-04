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
	SceneManager.returnBaseGame.connect(freeze_enemies)
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
		get_tree().get_first_node_in_group("run_end_screen").play_win()
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


var sleepTextSayings = ["Your eyes start to feel heavy as you drift away...", "Sleep pulls you under. You feel the dungeon drifting away...", "You feel the urge to close your eyes. Your mind starts to drift...", "Your sword start to feel heavy, you start to drift...", "The feeling of needing to close your eyes wins as you drift out of reality...", "The floor gives way beneath your thoughts, you drift away..."]

var dreamBuffStatSaying = ""
var dreamTextDreamBuffs = [ "increaseMaxHealth", "heal", "increaseSpeed", "increaseDamage"]
var dreamTextReturnSayings = ["You feel refreshed. ", 
							"Energy flows through your veins. ", 
							"You worries seem smaller now. ",
							"Your head feels clear and focused. ",
							"Your muscles feel loose and ready. ",
							"You grab your weapon with renewed confidence. ",
							"You stand up, ready for whatever's next. ",
							"You feel hoperful for what's ahead. "
							]

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
		
	return_saying_label.text = dreamTextReturnSayings[dreamTextReturnSayingsIndex] + "\n" + dreamBuffStatSaying
	return_saying_label.visible = true
	await get_tree().create_timer(5.0).timeout
	return_saying_label.visible = false
	
var nightmareDebuffStatSaying = ""
var nightmareTextNightmareDebuffs = ["decreaseMaxHealth", "decreaseSpeed", "decreaseDamage"]
var nightmareTextReturnSayings = ["Your hands are still trembling. ", 
									"The shadows look a little darker now. ", 
									"You feel drained as exhaustion pounds your head. ",
									"You aren't sure the nightmare is really over. ",
									"The silence feels heavier than before. ",
									"The air feels colder than before. ",
									"Something feels out of place. ",
									"The nightmare replays everytime you blink. "
									]
	
func chooseNightmareDebuff() -> void:
	
	var nightmareTextReturnSayingsIndex = randi_range(0, nightmareTextReturnSayings.size() - 1)
	var nightmareBuff = randi_range(0, nightmareTextNightmareDebuffs.size() - 1)
	var chosenNightmareDebuff = nightmareTextNightmareDebuffs[nightmareBuff]
	
	if chosenNightmareDebuff == "decreaseMaxHealth":
		player.changeMaxHealth(-10)
		nightmareDebuffStatSaying = "-10 max health"
	
	elif chosenNightmareDebuff == "decreaseSpeed":
		player.changeSpeed(-5)
		nightmareDebuffStatSaying = "-5 speed"
		
	elif chosenNightmareDebuff == "decreaseDamage":
		player.changeDamage(-10)
		nightmareDebuffStatSaying = "-10 damage"
		
	
	return_saying_label.text = nightmareTextReturnSayings[nightmareTextReturnSayingsIndex] + "\n" + nightmareDebuffStatSaying
	return_saying_label.visible = true
	await get_tree().create_timer(5.0).timeout
	return_saying_label.visible = false


func send_player_to_dream_sequence() -> void:
		
	var wasDream := justReturnedFromDream
	var wasNightmare := justReturnedFromNightmare
	
	reset_stats()
	
	if wasDream:
		chooseDreamBuff()
	
	elif wasNightmare:
		chooseNightmareDebuff()
	
	var dreamSequenceIndex = randi_range(0, dreamSequences.size() - 1)
	var randomTime = randf_range(30, 60) #choose a random time from 30 to a minute
	print("Sleeping in " + str(randomTime) + " seconds....")

	await get_tree().create_timer(randomTime - 5.0).timeout
	var sleepTextSayingsIndex = randi_range(0, sleepTextSayings.size() - 1)
	label.visible = true
	label.text = sleepTextSayings[sleepTextSayingsIndex]
	
	
	
	var regularPlayerSpeed = player.speed
	player.speed = 30
	fade.fade(1.0, 5.0)

	freeze_enemies(5.0)
	await get_tree().create_timer(5.0).timeout
	
	player.speed = regularPlayerSpeed

	RunDataState.timesDrifted += 1
	
	var dreamSequencesValue = dreamSequences[dreamSequenceIndex]
	justReturnedFromDream = dreamSequencesValueMap[dreamSequencesValue] == "dream"
	justReturnedFromNightmare = dreamSequencesValueMap[dreamSequencesValue] == "nightmare"
	
	SceneManager.enter_dream_scene(dreamSequencesValue)

func freeze_enemies(duration: float = 1.0) -> void:
	for node in find_children("*", "", true, false):
		if node is Enemy:
			node.freeze(duration)	
