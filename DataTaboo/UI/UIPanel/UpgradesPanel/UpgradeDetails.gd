extends Panel


export (String)var blank_upgrade_list_item = "res://DataTaboo/UI/ListItems/ListItemTypeZero.tscn"


func _ready():
	blank_upgrade_list_item = load("res://DataTaboo/UI/ListItems/ListItemTypeZero.tscn")


# Only hanldes applying the upgrade, should rename.
#
# Currency is handled by the UI via a signal sent from the list itself,
# wich is also triggered when the buy button is pressed.
func handle_list_item_buy_button(weapon, upgrade):
	upgrade.get_node("BuyButton").hide()
	
	Game.data.player_profile.equiped_weapons[weapon]["upgrades"][upgrade.id]["aquired"] = true
	Game.weapons_manager.call(upgrade.id, weapon)


func _on_Categories_list_item_arrow_button_pressed(item):
	$Upgrade/Description.text = Game.data.player_profile.equiped_weapons[item.id]["display_name"]
	
	if $SubUpgradesPanel/SubUpgradesList.upgrade_list != null:
		$SubUpgradesPanel/SubUpgradesList.upgrade_list.clear()
		
	$SubUpgradesPanel/SubUpgradesList.clear_list()
	
	
	var new_list_item = null
	var equipred_weapon_upgrades = Game.data.player_profile.equiped_weapons[item.id]["upgrades"]
	
	for available_upgrade in equipred_weapon_upgrades.keys():
		new_list_item = blank_upgrade_list_item.instance()
		new_list_item.id = available_upgrade
		
		new_list_item.get_node("Description").text =  \
			equipred_weapon_upgrades[available_upgrade]["display_name"] + "\n"
		
		new_list_item.get_node("Description").text += \
			equipred_weapon_upgrades[available_upgrade]["description"]
			
		new_list_item.get_node("ArrowButton").hide()
		
		if !Game.data.player_profile.equiped_weapons \
			[item.id]["upgrades"][available_upgrade]["aquired"]:
				new_list_item.get_node("BuyButton").connect(
					"pressed",
					self,
					"handle_list_item_buy_button",
					[item.id, new_list_item]
				)
				
		else:
			new_list_item.get_node("BuyButton").hide()
			
		$SubUpgradesPanel/SubUpgradesList.upgrade_list.append(new_list_item)


	$SubUpgradesPanel/SubUpgradesList.populate_list_with_instanced_items()
