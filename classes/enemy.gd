extends Entity
class_name Enemy

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var enemy_active := false
var my_room: RoomData = null
var currencyValue: int = 5
var freeze_timer := 0.0


func _ready() -> void:
	super()                       # runs Entity's _ready, if it has one
	set_physics_process(false)    # asleep until the player enters the room
	_find_my_room.call_deferred() # wait until the room is placed and the tracker is set up


func _physics_process(delta: float) -> void:
	
	if freeze_timer > 0.0:
		freeze_timer -= delta
		return #this return resets to the top of the code, freezing the enemy until the freeze timer is 0
	
	var player: Node2D = RoomTracker.player
	if is_instance_valid(player):
		velocity = global_position.direction_to(player.global_position) * speed

	if knockback_timer > 0.0:
		velocity = knockback
		knockback_timer -= delta
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO

	move_and_slide()


# --- Room activation ---

func _find_my_room() -> void:
	my_room = RoomTracker.room_at(global_position)
	if my_room == null:
		push_warning("%s spawned outside any room" % name)
		return

	if RoomTracker.current_room == my_room:
		activate()
	else:
		RoomTracker.room_entered.connect(_on_room_entered)


func _on_room_entered(room: RoomData) -> void:
	if room == my_room:
		activate()


func activate() -> void:
	if enemy_active:
		return
	enemy_active = true
	await get_tree().create_timer(1).timeout	# Delay the enemy from moving as player enters room
	set_physics_process(true)
	if RoomTracker.room_entered.is_connected(_on_room_entered):
		RoomTracker.room_entered.disconnect(_on_room_entered)


# --- Combat ---

func knockbackEnemy(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration


func takeDamage(amount: int) -> void:
	super(amount)
	activate()  # wake up if hit before the player enters (e.g. shot through a doorway)
	var player: Node2D = RoomTracker.player
	if is_instance_valid(player):
		var knockback_direction := (global_position - player.global_position).normalized()
		knockbackEnemy(knockback_direction, 150.0, 0.12)

func freeze(duration: float) -> void:
	freeze_timer = duration

func die() -> void:
	super()
	RunDataState.currency += currencyValue
	RunDataState.enemiesKilled += 1
