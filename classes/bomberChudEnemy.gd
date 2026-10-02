extends Enemy
class_name BomberChudEnemy

func _ready() -> void:
	super() #so entity _ready method isn't overwritten
	speed = 100.0
