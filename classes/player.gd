extends Entity
class_name Player

@onready var flip_anim: AnimationPlayer = $PlayerSprite/flip_anim
@onready var sword: Sprite2D = $PlayerSprite/SwordSprite
@onready var sword_anim: AnimationPlayer = $PlayerSprite/SwordSprite/AnimationPlayer
@onready var health_bar: ProgressBar = $"../Camera2D/PlayerHealthBar"
@onready var camera: Camera2D = $"../Camera2D"
@onready var end_screen: RunEndScreen = $"../RunEndScreen"

var is_dead := false

var curr_look_dir = "right"
var can_slash = true
@export var slash_time: float  = 0.2
@export var sword_return_time:float  = 0.5


func _ready() -> void:
	super() #so entity _ready method isn't overwritten
	speed = 150
	damage = 30
	
	add_to_group("player")
	health_bar.max_value = max_health
	health_bar.value = current_health

func takeDamage(amount: int) -> void:
	if is_dead:
		return
	super(amount)  # Entity calls die() here when health reaches 0
	health_bar.value = current_health

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()  # anything listening for the player's death still hears it
	velocity = Vector2.ZERO
	set_physics_process(false)
	end_screen.play_death(self, camera)

func heal(amount: int) -> void:
	super(amount)
	health_bar.value = current_health
	
func changeSpeed (amount: int) -> void:
	speed += amount
	
	if speed < 100:
		speed = 100 #set minimum speed to 100 so it doesn't go to negative

func changeMaxHealth (amount: int) -> void:
	max_health += amount
	heal(amount)
	health_bar.value = current_health
	
	if max_health < 50:
		max_health = 50 #set minimum maxhealth to 50 so it doesn't go to negative

func changeDamage (amount: int) -> void:
	damage += amount
	
	if damage < 10:
		damage = 10 #set minimum damage to 10 so it doesn't go to negative

func _physics_process(delta: float) -> void:

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed;
	move_and_slide()
	
	if curr_look_dir == "right" and get_global_mouse_position().x < global_position.x :
		flip_anim.play("look_left")
		curr_look_dir = "left"
	elif curr_look_dir == "left" and get_global_mouse_position().x > global_position.x :
		flip_anim.play("look_right")
		curr_look_dir = "right"
	
	if get_global_mouse_position().y > global_position.y:
		sword.show_behind_parent = false
		#$PlayerSprite.frame = 0
	else:
		sword.show_behind_parent = true
		#$PlayerSprite.frame = 1
		
	# SWORD SLASHING
	if Input.is_action_pressed("fire") and can_slash:
		sword_anim.speed_scale = sword_anim.get_animation("slash").length / slash_time
		sword_anim.play("slash")
		can_slash = false

const sword_slash_preload = preload("res://scenes/sword_slash.tscn")
func spawn_slash():
	var sword_slash_var = sword_slash_preload.instantiate()
	sword_slash_var.get_node("Sprite2D/AnimationPlayer").speed_scale = sword_slash_var.get_node("Sprite2D/AnimationPlayer").get_animation("sword_slash").length / slash_time
	sword_slash_var.get_node("Sprite2D").flip_v = false if get_global_mouse_position().x > global_position.x else true
	sword_slash_var.weapon_damage = damage
	sword_slash_var.scale *= RunDataState.attackRange
	add_child(sword_slash_var)
	
func reduceSlashTime():
	slash_time /= 1.2;
	sword_return_time /= 1.2


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "slash":
		sword_anim.speed_scale = sword_anim.get_animation("sword_return").length / sword_return_time
		sword_anim.play("sword_return")
	else:
		can_slash = true
