extends GridContainer

export (int) onready var slots = 7
var inventory = preload("res://Inventory/Inventory.tres")
var slot = preload("res://Inventory/InventorySlotDisplay.tscn")

func _ready():
	inventory.connect("items_changed", self, "_on_items_changed")
	update_inventory_display()
#	for num in range(slots - inventory.items.size()):
#		var new_slot = slot.instance();
#		new_slot
#		self.add_child(new_slot)
#		inventory.items.push_back(null)

func update_inventory_display():
	for item_index in inventory.items.size():
		update_inventory_slot_display(item_index)	

func update_inventory_slot_display(item_index):
	if item_index != inventory.items.size():
		var inventory_slot_display = get_child(item_index)
		var item = inventory.items[item_index]
		if inventory_slot_display != null and inventory_slot_display.name != 'ActionMenuBG' :
			inventory_slot_display.display_item(item)

func _on_items_changed(indexes):
	for item_index in indexes:
		update_inventory_slot_display(item_index)

func _unhandled_input(event):
	if event.is_action_released('ui_left_mouse'):
		if inventory.drag_data is Dictionary:
			inventory.set_item(inventory.drag_data.item_index, inventory.drag_data.item)
