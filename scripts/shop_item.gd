class_name ShopItem
extends Resource

@export var id: StringName
@export var title: String = "Item Title"
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var price: int = 10
@export var weight: float = 1.0
## Won't appear in shops before this floor.
@export var min_floor: int = 1
@export var effect: StringName


## Override in a subclass (e.g. `extends ShopItem` in heal_potion.gd) to give
## each item its own behaviour, same as the SO strategy pattern in Unity.
func apply(player: Node) -> void:
	if effect.is_empty():
		return
	if not ShopUpgradeEffects.has_method(effect):
		push_error("ShopEffects has no function '%s' (item: %s)" % [effect, title])
		return
	ShopUpgradeEffects.call(effect, player, self)
