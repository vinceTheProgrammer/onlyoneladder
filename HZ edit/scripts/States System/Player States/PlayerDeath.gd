extends State
class_name PlayerDeath


@export var ThisPlayer : CharacterBody2D


func State_Enter():
	ThisPlayer.anims.play("Death")
	print(name)


func State_Physics_Update(delta): 
	await get_tree().create_timer(3)
	get_tree().reload_current_scene()
	
	
	
	
