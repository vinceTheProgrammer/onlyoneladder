extends Node

var current_scene: Node = null
var gui_scene: Node = null

const GAME_SCENE_PATH := "res://scenes/game.tscn"
const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"
const GUI_SCENE_PATH := "res://scenes/ui/gui.tscn" # in-game ui

var game_paused := false

func _ready():
	load_gui()
	change_scene(MAIN_MENU_PATH)


func load_gui():
	if not gui_scene:
		gui_scene = preload(GUI_SCENE_PATH).instantiate()
		get_tree().get_root().add_child.call_deferred(gui_scene)
		gui_scene.set_z_index(1000)


func change_scene(scene_path: String):
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	var new_scene = load(scene_path).instantiate()
	get_tree().get_root().add_child.call_deferred(new_scene)
	current_scene = new_scene


func start_at_level(level_path: String):
	change_scene(GAME_SCENE_PATH)


func return_to_menu():
	change_scene(MAIN_MENU_PATH)


func pause_game():
	game_paused = true
	get_tree().paused = true
	gui_scene.call("show_pause_menu")


func resume_game():
	game_paused = false
	get_tree().paused = false
	gui_scene.call("hide_pause_menu")
