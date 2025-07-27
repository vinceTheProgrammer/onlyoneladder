extends Control


@onready var parent = get_parent()


@onready var resume: Button = $PanelContainer/Panel/VBoxContainer/Resume
@onready var quit: Button = $PanelContainer/Panel/VBoxContainer/Quit
@onready var btm: Button = $PanelContainer/Panel/VBoxContainer/BTM
@onready var restart: Button = $PanelContainer/Panel/VBoxContainer/Restart
@onready var options: Button = $PanelContainer/Panel/VBoxContainer/Options


var paused := false


func _ready() -> void:
	hide()





func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if paused == false:
			paused = true
			parent.process_mode = Node.PROCESS_MODE_DISABLED
			show()
		elif paused == true:
			parent.process_mode = Node.PROCESS_MODE_PAUSABLE
			paused = false
			hide()
			




func _on_resume_pressed() -> void:
	paused = false
	parent.process_mode = Node.PROCESS_MODE_PAUSABLE
	hide()



func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()




func _on_quit_pressed() -> void:
	get_tree().quit()
