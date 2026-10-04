extends Enemy
class_name RangedChudEnemy


@export var fire_rate := 1.5 # time between throws
const KNIFE = preload("uid://4c53cjsr0wvh")
@onready var attack_range: Area2D = $AttackRange

var fire_cooldown := 0.0 # current cooldown

func _ready() -> void:
	super()
	speed = 20	
	damage = 10

func _physics_process(delta: float) -> void:
	super(delta)
	
	fire_cooldown -= delta
	var player: Node2D = RoomTracker.player
	if fire_cooldown <= 0.0 and is_instance_valid(player) and attack_range.overlaps_body(player):
		throw_knife(player)
		fire_cooldown = fire_rate



func throw_knife(player: Node2D) -> void:
	var throwableKnife: Knife = KNIFE.instantiate()
	throwableKnife.damage = damage
	get_parent().add_child(throwableKnife)
	throwableKnife.global_position = global_position
	throwableKnife.rotation = global_position.direction_to(player.global_position).angle()
