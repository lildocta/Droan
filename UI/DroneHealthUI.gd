extends Control

export(int) var health setget set_health
export(int) var max_health setget set_max_health
export(int) var health_width

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty


func set_health(value):
	health = clamp(value, 0, max_health)
	if heartUIFull != null:
		heartUIFull.rect_size.x = health * health_width

func set_max_health(value):
	max_health = max(value, 1)
	self.health = min(health, max_health)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_health * health_width
	
func _ready():
	self.max_health = max_health
	self.health = max_health
