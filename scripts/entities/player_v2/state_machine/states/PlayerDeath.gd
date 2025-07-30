extends State
class_name PlayerDeath


@onready var ThisPlayer = get_parent().playerx

func State_Enter():
	ThisPlayer.anims.play("Death")
	print(name)


func State_Physics_Update(delta): 
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
	
	
	
	
