extends Node2D

const SAVE_DIR = "user://saves/"
var stats = PlayerStats

onready var console_label = $CanvasLayer/Control/SaveLoadWindow/Panel/VBoxContainer/Console/ScrollContainer/ConsoleLabel
onready var player = $YSort/Player
onready var warp_pad = $YSort/HomeWarpPad
onready var warp_animation = $YSort/HomeWarpPad/AnimationPlayer

func _ready():
	player.connect("no_health", self, "move_player")

func move_player():
	player.hide()	
	player.global_position = warp_pad.global_position - Vector2(0,-3)
	warp_animation.play("Warping")
	PlayerStats.health = PlayerStats.max_health
var save_path = SAVE_DIR + "save.dat"

func _on_SaveButton_pressed():
	var data = {
		"name" : "Paw Bearer",
		"jump_height" : 2.5,
		"max_health" : 6,
		"health" : 4,
		"strength" : 11,
	}
	
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
	
	var file = File.new()
#	var error = file.open(save_path, File.WRITE)
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "P@paB3ar6969")
	if error == OK:
		file.store_var(data)
		file.close()
	
	console_write("data saved")

func _on_LoadButton_pressed():
	var file = File.new()
	if file.file_exists(save_path):
#		var error = file.open(save_path, File.READ)
		var error = file.open_encrypted_with_pass(save_path, File.READ, "P@paB3ar6969")
		if error == OK:
			var player_data = file.get_var()
			file.close()
			console_write(player_data)
	
	console_write("data loaded")

func console_write(value):
	console_label.text += str(value) + "\n"


func _on_HomeWarpPad_show_player():
	player.show()
