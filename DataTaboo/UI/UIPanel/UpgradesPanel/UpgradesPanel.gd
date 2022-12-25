extends "res://DataTaboo/UI/UIPanel/UiPanel.gd"


var upgrades_data_source = null
var upgrades_list = null


func _ready():
	upgrades_list = $UpgradesList


func populate_list():
	if upgrades_data_source != null:
		upgrades_list.upgrade_list = upgrades_data_source
		upgrades_list.populate_list_instantiate_items()

func start_move_from_activation(_activated_item = "null"):
	.start_move_from_activation(_activated_item)
