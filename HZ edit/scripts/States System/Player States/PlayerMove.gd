extends State
class_name PlayerMove


@export var ThisPlayer : CharacterBody2D

var coyoteTime : float


func State_Enter():
	ThisPlayer.anims.play("Walk")
	print(name)
	coyoteTime = ThisPlayer.coyote_time


func State_Physics_Update(delta): 
	var dir = Input.get_axis(ThisPlayer.move_left_action, ThisPlayer.move_right_action)
	
	if dir > 0: ThisPlayer.anims.set_flip_h(false)
	elif dir < 0: ThisPlayer.anims.set_flip_h(true)
	
	ThisPlayer.velocity.x = lerp(ThisPlayer.velocity.x, dir * ThisPlayer.speed, 0.2) 
	if !dir:
		Transitioned.emit(self, "Idle")
	
	if Input.is_action_just_pressed(ThisPlayer.jump_action):
		ThisPlayer.velocity.y -= ThisPlayer.jump_force
		ThisPlayer.anims.play("Jump")
		Transitioned.emit(self, "Midair")
	
	
	if not ThisPlayer.is_on_floor():
		
		
		ThisPlayer.velocity.y += ThisPlayer.gravity * delta
		ThisPlayer.anims.play("Midair")
		#Transitioned.emit(self, "Midair")
		coyoteTime -= delta
		print(coyoteTime)
		
		if Input.is_action_just_pressed(ThisPlayer.jump_action) and coyoteTime > 0:
			ThisPlayer.velocity.y -= ThisPlayer.jump_force
			ThisPlayer.anims.play("Jump")
			Transitioned.emit(self, "Midair")
	
	
	
	
