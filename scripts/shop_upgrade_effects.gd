extends Node
## One function per shop item. The name must match the item's `effect` field.

func extendo_grip(player: Node, item: ShopItem) -> void:
	print("Bought Extendo Grip")
	print_stack()

func truffle_bar(player: Node, item: ShopItem) -> void:
	print("Bought Truffle Bar")
	print_stack()
