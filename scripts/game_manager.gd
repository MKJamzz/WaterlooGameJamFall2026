extends Node

@onready var lives_ui = $LivesContainer
@onready var coins_ui = $CoinContainer/CoinsUI
@onready var stage_ui = $StageContainer/StageUI



var lives = 6
var coins = 0 # currency to buy/upgrade towers
var stage_count = 1

func _ready():
	initializePlayerStats()

func initializePlayerStats():
	coins_ui.text = str(coins)
	stage_ui.text = "Stage " + str(stage_count)
	
	
#add functions for update these variables
