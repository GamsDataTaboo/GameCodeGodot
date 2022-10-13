extends Control


var item_grid

# Configuration
export (int)var size = 0
export (PackedScene) var item_slot
var item_slots = []
var space_left = 0
#--


func _ready():
	item_grid = $GridContainer

func _process(_delta):
	if(Input.is_action_just_released("inventory")):
		if(visible):
			hide()
			for item in $GridContainer.get_children():
				if(item.get_child_count() == 1):
					if item.get_child(0).is_mouseover:
						item.get_child(0)._on_Item_mouse_exited()
						break
		else: show()


# Item Slots
func add_item_slots(new_slots):
	for _i in range( new_slots ):
		item_grid.add_child( item_slot.instance() )
		item_slots.append( false )
	space_left += new_slots
	
func add_item_to_slot(item):
	for i in range(item_slots.size()):
		if !item_slots[i]:
			item_grid.get_child(i).add_child(item)
			item_slots[i] = true
			space_left -= 1
			return
			
func send_item_data(_agent):
	var items_to_send = []
	for i in range(item_slots.size()):
		if item_slots[i]:
			items_to_send.append(
				[str(item_grid.get_child(i).get_child(0).id), 1] )
	
	get_tree().get_nodes_in_group("http")[0]._on_Inventory_send_item_data(
		items_to_send)
		
func print_all_item_data(_agent):
	for i in range(item_slots.size()):
		if item_slots[i]:
			print(item_grid.get_child(i).get_child(0).id)
#--


func _on_Inventory_Button_pressed():
	if ! visible: show()
	else: hide()
