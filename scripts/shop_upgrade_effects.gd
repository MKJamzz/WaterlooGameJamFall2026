extends Node
## One function per shop item. The name must match the item's `effect` field.


func extendo_grip(player: Node, item: ShopItem) -> void:
	RunDataState.attackRange += 0.25


func truffle_bar(player: Node, item: ShopItem) -> void:
	player.changeMaxHealth(20)

# Reduces slash time by a factor of 20 percent
func hot_hands(player: Node, item: ShopItem) -> void:
	player.reduceSlashTime()


func stick_branches(player: Node, item: ShopItem) -> void:
	RunDataState.attackEnemiesPerAtk += 1;

func thicc_sticc(player: Node, item: ShopItem) -> void:
	player.changeDamage(15)
