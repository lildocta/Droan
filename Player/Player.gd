extends KinematicBody2D

export var MAX_SPEED = 80
export var ROLL_SPEED = 110
export var ACCELERATION = 500
export var FRICTION = 500
export var rotation_speed = PI

var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var state = MOVE

enum {
	MOVE,
	ROLL,
	ATTACK
}

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get('parameters/playback')
onready var shield_hitbox = $HitboxPivot/ShieldHitbox
onready var hurtbox = $Hurtbox
onready var drones = $Drones

signal no_health

func _ready():
	randomize()
	stats.connect("no_health", self, "death_animation")
	animation_tree.active = true
	shield_hitbox.knockback_vector = roll_vector

func death_animation():
	pass
	animation_player.play("Death")
	emit_signal("no_health")
	
func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	if velocity == null:
		velocity = Vector2.ZERO
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	input_vector = input_vector.normalized()
	if input_vector != Vector2.ZERO:
		shield_hitbox.knockback_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	elif Input.is_action_just_pressed("roll"):
		state = ROLL
	move()
	
func attack_state(delta):
	velocity = Vector2.ZERO
	animation_state.travel('Attack')

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel('Roll')
	move()

func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE
	velocity = velocity / 1.2
	
func move():
	velocity = move_and_slide(velocity)

func _on_Hurtbox_area_entered(area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
