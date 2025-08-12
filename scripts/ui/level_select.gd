extends Control

@onready var test_level_preview: Sprite2D = $"Test-level-preview"

@onready var item_list: Tree = $ItemList



var level_num : int

var level_address : String = "res://scenes/levels/level_%d.tscn" % level_num


func confirm_level():
	if level_address != null:
		get_parent().level_address = level_address
		get_parent().camera.position = get_parent().customize_mark.global_position


func _on_item_list_item_selected() -> void:
	level_num = item_list.get_selected_column() + 1
