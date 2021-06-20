extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var FRICTION = 200
export var HURTKNOCKBACK = 130
export var ACCELERATION = 300
export var MAXSPEED = 50
export var WANDERTARGETRANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE,
	DEATH
}
var velocity = Vector2.ZERO
var state = IDLE
var knockback = Vector2.ZERO
var first_sighting = true

onready var stats = $Stats
onready var player_detection_zone = $Detection
onready var sprite = $EnemyAnimation
onready var enemy_death = $EnemyDeath
onready var hurtbox = $Hurtbox
onready var hurtbox_collision = $Hurtbox/HurtboxCollision
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController

func _ready():
	state = WANDER

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			check_for_new_state()
		WANDER:
			check_for_new_state()
			var direction = global_position.direction_to(wander_controller.target_position)
			velocity = velocity.move_toward(direction * MAXSPEED, ACCELERATION * delta)
			if global_position.distance_to(wander_controller.target_position) <= WANDERTARGETRANGE:
				state = pick_random_state([IDLE, WANDER])
				wander_controller.start_wander_timer(rand_range(1,3))
			sprite.flip_h = velocity.x < 0
			
		CHASE:
			var player = player_detection_zone.player
			if player != null:
				if first_sighting == true:
					first_sighting = false
					sprite.play()
				var direction = global_position.direction_to(player.global_position)
				velocity = velocity.move_toward(direction * MAXSPEED, ACCELERATION * delta)
			else :
				state = IDLE
			sprite.flip_h = velocity.x < 0
		DEATH:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func check_for_new_state():
	if wander_controller.get_time_left() == 0:
		state = pick_random_state([IDLE, WANDER])
		wander_controller.start_wander_timer(rand_range(1,3))

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list[0]

func _on_Hurtbox_area_entered(area):
	knockback = area.knockback_vector * 120
	stats.health -= area.damage
	if area.damage != 0:
		hurtbox.create_hit_effect()
	
func _on_Stats_no_health():
	if enemy_death != null:
		state = DEATH
		hurtbox_collision.disabled = true
		sprite.hide()
		enemy_death.flip_h = sprite.flip_h
		enemy_death.show()
		enemy_death.play()
	else :
		var enemyDeathEffect = EnemyDeathEffect.instance()
		get_parent().add_child(enemyDeathEffect)
		enemyDeathEffect.global_position = global_position
		queue_free()

func _on_EnemyDeath_animation_finished():
	queue_free()


func _on_Hitbox_area_entered(area):
	knockback = area.knockback_vector * 120
