extends Node

# Signals
signal currency_changed(new_amount: int)

# Variables
var currency: int = 0:
	set(value):
		currency = value
		currency_changed.emit(currency)

var enemiesKilled = 0

var attackSpeed = 1
var attackRange = 1
var attackEnemiesPerAtk = 1

var timesDrifted = 0
var floorsCleared = 0
var died = false

# Resets all stats in run to base
func resetRunStats():
	currency = 0
	enemiesKilled = 0
	attackSpeed = 1
	attackRange = 1
	attackEnemiesPerAtk = 1
	timesDrifted = 0
	floorsCleared = 0
	died = false
	print("Reset Stats")
