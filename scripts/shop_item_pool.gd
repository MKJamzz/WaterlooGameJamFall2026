class_name ShopItemPool
extends Resource
## A list of every item that can show up in shops. Make one .tres of this and
## drag your ShopItem .tres files into the `items` array in the Inspector.

@export var items: Array[ShopItem] = []


## Weighted pick of `count` unique items that are allowed on this floor.
func roll(count: int, floor_number: int) -> Array[ShopItem]:
	var candidates: Array[ShopItem] = []
	candidates.assign(items.filter(
		func(i: ShopItem) -> bool: return i != null and i.min_floor <= floor_number
	))

	var result: Array[ShopItem] = []
	while result.size() < count and not candidates.is_empty():
		var total := 0.0
		for item in candidates:
			total += item.weight

		var r := randf() * total
		var pick := candidates.size() - 1
		for idx in candidates.size():
			r -= candidates[idx].weight
			if r <= 0.0:
				pick = idx
				break

		result.append(candidates[pick])
		candidates.remove_at(pick)  # no duplicates in one shop

	return result
