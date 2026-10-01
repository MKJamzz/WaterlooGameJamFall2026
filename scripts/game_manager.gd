extends Node

@onready var lives_ui = $LivesContainer/LivesUI
@onready var coins_ui = $CoinContainer/CoinsUI
@onready var waves_ui = $WavesContainer/WavesUI


var lives = 150 
var coins = 0 # currency to buy/upgrade towers
var wave_count = 1

func _ready():
	initializePlayerStats()

func initializePlayerStats():
	lives_ui.text = str(lives)
	coins_ui.text = str(coins)
	waves_ui.text = "Wave " + str(wave_count)
	
	
#add functions for update these variables
