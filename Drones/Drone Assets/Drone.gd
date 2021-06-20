extends KinematicBody2D

export var ACCELERATION = 200
export var MAXSPEED = 70
export var WANDERTARGETRANGE = 4
export(NodePath) var parent_path = null
export var FRICTION = 200
export var deactive_time = 4

enum {
	ATTACK,
	EVADE,
	FOLLOW,
	DEFENSE
	IDLE,
	DEACTIVE,
	ACTIVATING,
	DEACTIVATING
}
var state = FOLLOW
var velocity = Vector2.ZERO
var parent = null
var just_activated = false
var can_activate = true
var rng = RandomNumberGenerator.new()

onready var wander_controller = $WanderController
onready var sprite = $AnimationPlayer
onready var soft_collision = $SoftCollision
onready var player_detection_zone = $Detection
onready var health_ui = $HealthUI
onready var hurtbox = $Hurtbox
onready var reactivate_timer = $ReactivationTimer
onready var drone_light = $DroneLight
onready var drone_shield = $DroneShield
onready var drone_knockback = $ShieldHitbox/Hitbox
onready var drone_hurtbox = $Hurtbox
onready var shield_hitbox = $ShieldHitbox/Hitbox/ShieldHitboxCollision
onready var shield_reactivate = $ShieldReactivate
onready var hitbox = $ShieldHitbox/Hitbox
var player_stats = PlayerStats

func _ready():
	player_stats.connect("no_health", self, "deactivate")
	health_ui.connect("no_health", self, "deactivate")
	health_ui.hide()
	parent = get_node(parent_path)
	sprite.play("Activating")
	state = FOLLOW
	
func _physics_process(delta): 
	update_drone_light()
#	Drone Movement
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			avoid_drones(delta)
			flip_sprite()
		FOLLOW:
			var player = player_detection_zone.player
			if player == null:
				find_player(delta)	
			else :
				state = IDLE
			avoid_drones(delta)
			flip_sprite()
		ACTIVATING:
			soft_collision.get_child(0).disabled = false
			health_ui.health = health_ui.max_health
			sprite.play("Activating")
			just_activated = true
			state = IDLE
		DEACTIVATING:
			sprite.play("Deactivating")
			velocity = Vector2.ZERO
		DEACTIVE:
			soft_collision.get_child(0).disabled = true
			health_ui.hide()
			sprite.play("Deactive")
			if health_ui.health > 0 :
				activate()
			
	velocity = move_and_slide(velocity)


#updates drone light to white and bright	
func set_white_bright():
	drone_light.show()
	drone_light.color = '#ffffff'
	drone_light.energy = 0.75

#Update the light color and intensity of drones lights
func update_drone_light():
	match state:
		IDLE:
			set_white_bright()
		FOLLOW:
			set_white_bright()
		DEFENSE:
			drone_light.show()
			drone_light.color = '#cf573c'
			drone_light.energy = 1
		ACTIVATING:
			drone_light.show()
			if rng.randi_range(0,1) == 0:
				drone_light.show()
				drone_light.color = '#4e9348'
			else :
				drone_light.hide()
		DEACTIVATING:
			if rng.randi_range(0,15) != 0:
				drone_light.show()
				drone_light.color = '#cf573c'
			else :
				drone_light.hide()
		DEACTIVE:
			drone_light.hide()
			
#Make Drone face direction they are moving
func flip_sprite():
	if velocity.x > 0: 
		sprite.play("ActiveRight")
	elif velocity.x < 0:
		sprite.play("ActiveLeft")
	elif just_activated and sprite.is_playing() == false:	
		sprite.play("ActiveRight")

#Set drone to move towards the player
func find_player(delta):
	if parent != null:
		var direction = global_position.direction_to(parent.global_position)
		velocity = velocity.move_toward(direction * MAXSPEED, ACCELERATION * delta)

#Keep drones from overlapping
func avoid_drones(delta):	
	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 400

#Determine if drone can see the player
func seek_player():
	if player_detection_zone.can_see_player():
		state = IDLE
	elif state != ATTACK and state != EVADE:
		state = FOLLOW

#Turn drone on
func activate():
	if player_detection_zone.can_see_player():	
		state = ACTIVATING

#Turn drone off
func deactivate():
	state = DEACTIVATING
	
#Take damage effects and damage cooldown timer
func _on_Hurtbox_area_entered(area):
	if !hurtbox.invincible and health_ui.health > 0:
		health_ui.health -= area.damage
		if health_ui.health > 0:
			health_ui.show()
		if health_ui.health == 0:
			state = DEACTIVATING
			if reactivate_timer != null:
				reactivate_timer.start(deactive_time)
		else:
			hurtbox.create_hit_effect()
			hurtbox.start_invincibility(2.5)

func _on_DroneStats_no_health():
	deactivate()

#when timer ends the player can wake the drone up again by getting in its detection zone
func _on_ReactivationWait_timeout():
	health_ui.health = health_ui.max_health

#Reactivate drone shield visibility and toggle health visibility
func _on_Hurtbox_invincibility_ended():
	if health_ui.health > 1:
		health_ui.hide()
	else:
		health_ui.show()

#Listen for Death animation finishing
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Deactivating":
		state = DEACTIVE
