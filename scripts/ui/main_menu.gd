extends Node


func _on_new_game_pressed() -> void:
	var next_scene = LevelDatabase.LEVEL_PATHS.LEVEL1
	if next_scene:
		GameManager.change_scene(next_scene)
