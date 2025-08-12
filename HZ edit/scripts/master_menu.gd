extends Node2D


var level_address : String



@onready var bg_mat = $CanvasLayer/BG.material

@onready var camera: Camera2D = $Camera2D



# position markers per menu
@onready var menu_mark: Marker2D = $"Main Menu/MenuMark"
@onready var options_mark: Marker2D = $Options/OptionsMark
@onready var lvl_menu_mark: Marker2D = $"Level Select/LvlMenuMark"
@onready var lvl_select_mark: Marker2D = $LevelSelect/LvlSelectMark
@onready var customize_mark: Marker2D = $Customization/CusMark


var main_color : Color

func _ready() -> void:
	main_color = bg_mat.get_shader_parameter("base_color")







func tween_bg_color_to(end_color: Color):
	var cur_color = bg_mat.get_shader_parameter("base_color")
	var tween = create_tween()
	
	
	tween.tween_method(
		func(c: Color):
			bg_mat.set_shader_parameter("base_color", c),
			cur_color,
			end_color,
			1.0
	)


func back_to_main():
	camera.position = menu_mark.global_position
	tween_bg_color_to(main_color)

#button signals





#main menu

func _on_settings_pressed() -> void:
	camera.position = options_mark.global_position
	tween_bg_color_to(Color.DARK_BLUE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func new_game():
	level_address = "res://scenes/levels/level_1.tscn"
	camera.position = customize_mark.global_position


# options

func _on_options_back_pressed() -> void:
	back_to_main()


# lvl select


func _on_level_select_pressed() -> void:
	camera.position = lvl_select_mark.global_position
	tween_bg_color_to(Color.DARK_GREEN)





func _on_lvl_back_pressed() -> void:
	back_to_main()
