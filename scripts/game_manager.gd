extends Node

@onready var lives_ui = $LivesContainer/LivesUI
@onready var coins_ui = $CoinContainer/CoinsUI


var lives = 150 
var coins = 0 # currency to buy/upgrade towers

func _ready():
	initializeLivesAndCoinAmount()

func initializeLivesAndCoinAmount():
	lives_ui.text = str(lives)
	coins_ui.text = str(coins)
	
	
#add functions for update these variables
