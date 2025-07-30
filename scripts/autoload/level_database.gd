extends Node

const LEVEL_PATHS := {
	"LEVEL1": "res://scenes/levels/level_1.tscn",
}

const LEVEL_ORDER = [
	LEVEL_PATHS["LEVEL1"],
]

func get_level_scene(name: String) -> PackedScene:
	var path = LEVEL_PATHS.get(name, null)
	return path if path == null else load(path)
