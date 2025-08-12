extends Tree




func _ready() -> void:
	var root = create_item()
	hide_root = true
	for n in 4:
		create_dummy_chapter(n + 1)
	
func create_dummy_chapter(chapter_number: int) -> void:
	var chapter = create_item()
	chapter.set_selectable(0, false)
	chapter.collapsed = true
	chapter.set_text(0, "Chapter %d" % chapter_number)
	for n in 20:
		create_dummy_level(n + 1, chapter)
		
func create_dummy_level(level_number: int, chapter: TreeItem) -> void:
	var level = create_item(chapter)
	level.set_text(0, "Level %d" % level_number)
