extends ScrollContainer


signal list_item_arrow_button_pressed
signal list_item_buy_button_pressed


export (Array, PackedScene)var upgrade_list = null
export (Array, PackedScene)var upgrade_list_items_ui = null

export (bool)var populate_on_ready = true
export (int)var default_upgrade_list_item_ui_index = 0
var upgrade_list_items_ui_active_index = 1

export (String)var currency_source_node = "Game"
export (String)var currency_get_function = "get_game_currency"


func _ready():
	currency_source_node = get_tree().root.get_node(currency_source_node)
	upgrade_list_items_ui_active_index = default_upgrade_list_item_ui_index
	
	if populate_on_ready:
		populate_list_instantiate_items()


func populate_list_instantiate_items():
	for item in upgrade_list.keys():
		var new_item = upgrade_list_items_ui[upgrade_list_items_ui_active_index].instance()
		new_item.id = item
		
		new_item.get_node("Description").text = upgrade_list[item].display_name + "\n"
		new_item.get_node("Description").text += upgrade_list[item].description
		
		new_item.get_node("ArrowButton").connect(
			"pressed",
			self,
			"handle_list_item_arrow_button",
			[new_item]
		)
		
		new_item.get_node("BuyButton").connect(
			"pressed",
			self,
			"handle_list_item_buy_button",
			[new_item]
		)
			
		if currency_source_node.call(currency_get_function) > 0:
			new_item.get_node("BuyButton").disabled = false
			
		else:
			new_item.get_node("BuyButton").disabled = true
		
		$GridContainer.add_child(new_item)

func populate_list_with_instanced_items():
	for item in upgrade_list:
		item.get_node("ArrowButton").connect(
			"pressed",
			self,
			"handle_list_item_arrow_button",
			[item]
		)
		
		item.get_node("BuyButton").connect(
			"pressed",
			self,
			"handle_list_item_buy_button",
			[item]
		)
		
		if currency_source_node.call(currency_get_function) > 0:
			item.get_node("BuyButton").disabled = false
			
		else:
			item.get_node("BuyButton").disabled = true
		
		
		$GridContainer.add_child(item)


func check_currency_update_enable_or_disable_buttons():
	for item in $GridContainer.get_children():
		if currency_source_node.call(currency_get_function) > 0:
			item.get_node("BuyButton").disabled = false
			
		else:
			item.get_node("BuyButton").disabled = true

func clear_list():
	for item in $GridContainer.get_children():
		item.queue_free()


func handle_list_item_arrow_button(item):
	emit_signal("list_item_arrow_button_pressed", item)

func handle_list_item_buy_button(item):
	emit_signal("list_item_buy_button_pressed", item)
