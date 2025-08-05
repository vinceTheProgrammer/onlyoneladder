extends State
class_name PlayerLadderState


@onready var ThisPlayer = get_parent().playerx

func State_Enter():
	ThisPlayer.anims.play("Climb")
	ThisPlayer.anims.pause()
	print(name)


func State_Physics_Update(delta): 
	pass
	
	
	
	
