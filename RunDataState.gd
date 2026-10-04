extends Node
## Autoload "RunDataState": everything specific to the current run.
## Now also owns the shop state (replaces the separate GameState autoload).

# Signals
signal currency_changed(new_amount: int)
signal shop_stock_changed
signal item_purchased(item: ShopItem)

# Shop config. Change the path to wherever your pool .tres lives.
const SHOP_POOL: ShopItemPool = preload("res://data/shop/shop_pool.tres")
const SHOP_SIZE := 3

# Variables
var currency: int = 0:
	set(value):
		currency = value
		currency_changed.emit(currency)

var enemiesKilled = 0
var attackRange: float = 1.0

var attackEnemiesPerAtk = 1

var timesDrifted = 0
var floorsCleared = 0
var died = false

const DEATH_MULTIPLIER:= 0.8

# Shop state (rolled once per floor)
var _shop_stock: Array[ShopItem] = []
var _shop_sold: Array[ShopItem] = []
var _shop_floor := -1


# Resets all stats in run to base
func resetRunStats():
	currency = 0
	enemiesKilled = 0
	attackRange = 1.0
	attackEnemiesPerAtk = 1
	timesDrifted = 0
	floorsCleared = 0
	died = false
	_shop_stock = []
	_shop_sold = []
	_shop_floor = -1
	print("Reset Stats")


func getCurrentFloor() -> int:
	return floorsCleared + 1


# Rolls new stock the first time it's asked for on a new floor,
# then returns the same items for the rest of that floor.
func getShopStock() -> Array[ShopItem]:
	if _shop_floor != getCurrentFloor():
		_shop_floor = getCurrentFloor()
		_shop_stock = SHOP_POOL.roll(SHOP_SIZE, _shop_floor)
		_shop_sold = []
	return _shop_stock


func isSold(item: ShopItem) -> bool:
	return item in _shop_sold


func tryBuy(item: ShopItem) -> bool:
	if item not in getShopStock() or isSold(item) or currency < item.price:
		return false
	currency -= item.price
	_shop_sold.append(item)
	item_purchased.emit(item)  # player can listen and call item.apply(self)
	shop_stock_changed.emit()
	var player = get_tree().get_first_node_in_group("player")
	item.apply(player)
	return true
	

func calculateScore(won: bool) -> int:
	var base :int = currency * 5 + enemiesKilled * 30 + timesDrifted * 20
	var multiplier := 1.0 if won else DEATH_MULTIPLIER
	return int(base * floorsCleared * multiplier)
