extends State
class_name PlayerLadder


@onready var ThisPlayer = get_parent().playerx

var ladder: Ladder
var ladder_vertical_offset: float
var ladder_vertical_velocity: float

func State_Enter():
	print(name)
	ThisPlayer.anims.play("Climb")
	ThisPlayer.anims.pause()
	
	if ThisPlayer.target_ladder == null:
		Transitioned.emit(self, "Idle")
		return
			
	init_ladder_climb()
	
func State_Update(delta):
	
	
	if ladder_vertical_velocity < 0.0: ThisPlayer.anims.play()
	
	elif ladder_vertical_velocity > 0.0: ThisPlayer.anims.play_backwards()
	
	ThisPlayer.anims.rotation = ladder.rotation


func State_Physics_Update(delta): 
	var input_direction: Vector2 = Input.get_vector(ThisPlayer.move_left_action, ThisPlayer.move_right_action, ThisPlayer.move_left_action, ThisPlayer.move_right_action)
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
		
	var ladder_direction: Vector2 = Vector2(cos(ladder.rotation), -sin(ladder.rotation))
	var ladder_direction_rotated: Vector2 = Vector2(-ladder_direction.y, ladder_direction.x)
	
	var dot_product: float = input_direction.dot(ladder_direction_rotated)
	var projection_of_input_onto_ladder: float = dot_product / ladder_direction_rotated.length()
	
	ladder_vertical_velocity = Globals.lerp_smooth(ladder_vertical_velocity, -projection_of_input_onto_ladder * ThisPlayer.ladder_speed, 0.6, delta)
	ladder_vertical_offset = clampf(ladder_vertical_offset + ladder_vertical_velocity * delta, ladder.END_Y_OFFSET, ladder.START_Y_OFFSET)
	
	var local_position_on_ladder := Vector2(0, ladder_vertical_offset)
	var global_position_on_ladder: Vector2 = ladder.to_global(local_position_on_ladder)
	ThisPlayer.global_position = global_position_on_ladder
	
	if !input_direction: ThisPlayer.anims.pause()
	
	if Input.is_action_just_pressed(ThisPlayer.jump_action):
		deinit_ladder_climb()
		ThisPlayer.velocity.y -= ThisPlayer.jump_force
		ThisPlayer.anims.play("Jump")
		Transitioned.emit(self, "Midair")
	
func init_ladder_climb() -> void:
	ladder = ThisPlayer.target_ladder
	var local_pos_on_ladder := ladder.to_local(ThisPlayer.global_position)
	ladder_vertical_offset = clampf(local_pos_on_ladder.y, ladder.END_Y_OFFSET, ladder.START_Y_OFFSET)
	add_self_to_ladder_array(ladder)
	ThisPlayer.velocity = Vector2.ZERO
	
func deinit_ladder_climb() -> void:
	remove_self_from_ladder_array(ladder)
	ladder = null
	ThisPlayer.anims.rotation = 0.0

func add_self_to_ladder_array(ladder: Ladder) -> void:
	if not ladder.players_currently_climbing.has(ThisPlayer):
		ladder.players_currently_climbing.append(ThisPlayer)
		
func remove_self_from_ladder_array(ladder: Ladder) -> void:
	ladder.players_currently_climbing.erase(ThisPlayer)
	
	
	
