extends State
class_name PlayerDeath


@onready var ThisPlayer = get_parent().playerx

@export var death_duration: float = 1 ##The amount of time it takes to restart the level after a player dies (in seconds).

func State_Enter():
	ThisPlayer.anims.play("Death")
	print(name)


func State_Physics_Update(delta): 
	await get_tree().create_timer(death_duration).timeout
	get_tree().reload_current_scene()
	
	
	
	
