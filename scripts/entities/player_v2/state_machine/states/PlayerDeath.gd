extends State
class_name PlayerDeath


@onready var ThisPlayer = get_parent().playerx

const DEATH_DURATION: int = 1

func State_Enter():
	ThisPlayer.anims.play("Death")
	print(name)


func State_Physics_Update(delta): 
	await get_tree().create_timer(DEATH_DURATION).timeout
	get_tree().reload_current_scene()
	
	
	
	
