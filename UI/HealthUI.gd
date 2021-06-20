extends Control

export(int) var hearts = 4 setget set_hearts
export(int) var max_hearts = 4 setget set_max_hearts
export(int) var health_width

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * health_width

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * health_width
	
func _ready():
	self.max_hearts = max_hearts
	self.hearts = hearts
	PlayerStats.connect("health_changed", self, "set_hearts")
	PlayerStats.connect("max_health_changed", self, "set_max_hearts")
