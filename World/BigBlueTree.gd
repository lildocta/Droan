extends Node2D


onready var tree_sprite = $BigBlueTreeSprite
onready var tween = $Tween
var random_direction_chosen = false

func _ready():
	if random_direction_chosen == false:
		var rand = int(rand_range(0,3))
		if rand > 1:
			tree_sprite.flip_h = true
		random_direction_chosen = true

func _on_TreeVisibility_area_entered(area):
	tween.interpolate_property(tree_sprite, "modulate:a", 
	1,0.7, 1.0, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func _on_TreeVisibility_area_exited(area):
	tween.interpolate_property(tree_sprite, "modulate:a", 
	0.7,1, 1.0, 
	Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

