extends Entity
class_name Player



func _ready() -> void:
	super() #so entity _ready method isn't overwritten
	speed = 150.0

func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed;
	move_and_slide()
	
	
