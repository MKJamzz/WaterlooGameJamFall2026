class_name ShopCard
extends ColorRect
## Attach to the root `shopCard` node of shop_card.tscn.
## The card knows nothing about coins or stock. It just shows an item and
## announces "someone clicked buy" through a signal.

signal buy_pressed(item: ShopItem)

# Paths match your current tree. Update these if you rename or move nodes.
@onready var title_label: Label = $VBoxContainer/Label
@onready var icon_rect: TextureRect = $VBoxContainer/TextureRect
@onready var desc_label: RichTextLabel = $Bottom/ItemDesc
@onready var buy_button: Button = $Bottom/Button

var item: ShopItem


func _ready() -> void:
	buy_button.pressed.connect(func() -> void: buy_pressed.emit(item))


## Must be called AFTER the card is in the tree (add_child first), or the
## @onready vars above will still be null.
func setup(new_item: ShopItem, sold := false) -> void:
	item = new_item
	title_label.text = item.title
	icon_rect.texture = item.icon
	desc_label.text = item.description
	set_sold(sold)


func set_sold(sold: bool) -> void:
	buy_button.disabled = sold
	buy_button.text = "SOLD" if sold else "%d Coins" % item.price
