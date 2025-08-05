extends State
class_name PlayerMidair


@onready var ThisPlayer = get_parent().playerx

func State_Enter():
	print(name)
	if ThisPlayer.anims.get_animation() == "Jump" and !ThisPlayer.anims.is_playing():
		ThisPlayer.anims.play("Midair")
	


func State_Physics_Update(delta): 
	
	ThisPlayer.velocity.y += ThisPlayer.gravity * delta
	
	var dir = Input.get_axis(ThisPlayer.move_left_action, ThisPlayer.move_right_action)
	
	if dir > 0: ThisPlayer.anims.set_flip_h(false)
	elif dir < 0: ThisPlayer.anims.set_flip_h(true)
	
	if !Input.is_action_pressed(ThisPlayer.jump_action) and ThisPlayer.velocity.y<0: #Only triggers when player is moving up airborne and not holding down jump key
		ThisPlayer.velocity.y /= (2) #changes y velocity if jump key not being held, allows finer jump height control
		print(ThisPlayer.velocity.y)
	ThisPlayer.velocity.x = lerp(ThisPlayer.velocity.x, dir * ThisPlayer.speed, 0.2) 
	if ThisPlayer.is_on_floor():
		Transitioned.emit(self, "Idle")
