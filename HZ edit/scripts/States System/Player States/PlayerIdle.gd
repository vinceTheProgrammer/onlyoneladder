extends State
class_name PlayerIdle


@export var ThisPlayer : CharacterBody2D


func State_Enter():
	ThisPlayer.anims.play("Idle")
	print(name)


func State_Physics_Update(delta): 
	
	if abs(ThisPlayer.velocity.x) > 0:
		ThisPlayer.velocity.x = lerp(ThisPlayer.velocity.x, 0.0, 0.4)
	
	
	if Input.get_axis(ThisPlayer.move_left_action, ThisPlayer.move_right_action):
		Transitioned.emit(self, "Moving")
	
	
	if Input.is_action_just_pressed(ThisPlayer.jump_action):
		if Input.is_action_just_pressed(ThisPlayer.jump_action):
			ThisPlayer.velocity.y -= ThisPlayer.jump_force
			ThisPlayer.anims.play("Jump")
			Transitioned.emit(self, "Midair")
	
	
	
	
	if !ThisPlayer.is_on_floor():
		Transitioned.emit(self, "Midair")
	
	
	
