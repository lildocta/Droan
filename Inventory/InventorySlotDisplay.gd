extends CenterContainer

onready var item_texture_rect = $ItemTextureRec
onready var inventory = preload("res://Inventory/Inventory.tres")
onready var item_empty_slot = preload("res://Inventory/Item/Item Assets/EmptySlot.png")
onready var camera = get_parent().get_parent().get_parent()
		
func display_item(item):
	if item is Item:
		item_texture_rect.texture = item.texture
	else:
		item_texture_rect.texture = item_empty_slot

func get_drag_data(_position):
	var item_index = get_index()
	var item = inventory.remove_item(item_index)
	if item is Item:
		var data = {}
		data.item = item
		data.item_index = item_index
		var preview = Control.new()
		var drag_preview = Sprite.new()
		if(camera.name != 'Camera2D'):
			camera = get_parent()
		drag_preview.position = camera.global_position
		drag_preview.texture = item.texture
		drag_preview.z_index = 15
		preview.add_child(drag_preview)
		set_drag_preview(preview)
		return data

func can_drop_data(_position, data):
	return data is Dictionary and data.has("item")

func drop_data(_position, data):
	var my_item_index = get_index()
	var my_item = inventory.items[my_item_index]
	inventory.swap_items(my_item_index, data.item_index)
	inventory.set_item(my_item_index, data.item)
