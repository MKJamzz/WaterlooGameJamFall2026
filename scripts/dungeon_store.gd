extends Control
## Attach to the root `dungeonStorePopup` node of dungeon_store.tscn.

signal closed

## Drag shop_card.tscn here in the Inspector (Unity: a prefab reference field).
@export var card_scene: PackedScene = preload("res://scenes/UI/shop_card.tscn")

@onready var cards_container: HBoxContainer = \
	$MarginContainer/ColorRect/VBoxContainer/MarginContainer/HBoxCards
@onready var exit_button: Button = \
	$MarginContainer/ColorRect/MarginContainer/ExitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep working while the game is paused
	hide()
	exit_button.pressed.connect(close)
	RunDataState.shop_stock_changed.connect(_refresh)


func open() -> void:
	_refresh()
	show()
	get_tree().paused = true


func close() -> void:
	hide()
	get_tree().paused = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):  # Esc also closes
		close()
		get_viewport().set_input_as_handled()


## Rebuild the cards from RunDataState. The 3 cards placed in the editor are
## cleared here, so you can keep them as a layout preview.
func _refresh() -> void:
	for child in cards_container.get_children():
		child.queue_free()

	for item in RunDataState.getShopStock():
		var card: ShopCard = card_scene.instantiate()
		cards_container.add_child(card)
		card.setup(item, RunDataState.isSold(item))
		card.buy_pressed.connect(_on_buy_pressed)


func _on_buy_pressed(item: ShopItem) -> void:
	if not RunDataState.tryBuy(item):
		pass  # not enough coins: shake the card, play a sound, etc.
