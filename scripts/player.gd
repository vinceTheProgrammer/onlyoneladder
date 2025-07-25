extends CharacterBody2D
class_name Player

@export var player_id: int = 1
@export var player_color: Color = Color.RED;
@onready var move_left_action := "move_left_player%d" % player_id
@onready var move_right_action := "move_right_player%d" % player_id
@onready var move_down_action := "move_down_player%d" % player_id
@onready var move_up_action := "move_up_player%d" % player_id
@onready var jump_action := "jump_player%d" % player_id
@onready var ability_action := "grab_player%d" % player_id
@onready var sprite = $AnimatedSprite2D

const GRAVITY = 980.0 # pixels/sec^2
const JUMP_SPEED = -300.0
const MOVE_SPEED = 200.0
const LADDER_MOVE_SPEED = 100.0
const LADDER_MOVE_SPEED_HORIZONTAL = 10.0
const MASS = 5.0
const GRAB_HOLD_THRESHOLD = 0.5
const JUMP_BUFFER_TIME := 0.15
const COYOTE_TIME_LENGTH = 0.2
const LADDER_COYOTE_TIME_LENGTH = 0.3
const DIE_ANIMATION_LENGTH = 1.0
const JUMP_ANIMATION_LENGTH = 1.0

var spawn_point: SpawnPoint
var dying: bool = false
var jumping: bool = false
var remaining_coyote_time: float = COYOTE_TIME_LENGTH
var die_animation_time_remaining: float = DIE_ANIMATION_LENGTH
var jump_animation_time_remaining: float = JUMP_ANIMATION_LENGTH
var current_ladder: Ladder
var target_ladder: Ladder
var ladder_offset := 0.0
var ladder_offset_horizontal := 0.0
var ladder_velocity := 0.0
var ladder_velocity_horizontal := 0.0
var grab_joint: PinJoint2D = null
var grabbed_body: RigidBody2D = null
var grab_hold_timer := 0.0
var grab_input_held: bool = false
var is_grounded: bool = false
var jump_buffer_timer := 0.0
var ladder_was_upside_down_when_climbed: bool = false

func _ready() -> void:
	set_spawn_point()
	
# TODO: let the level loader do this
func set_spawn_point() -> void:
	var spawn_points = get_tree().get_nodes_in_group("spawn_point")
	
	var target_spawn_point = spawn_points.filter(func(s): return s.player_id == player_id).front()
	if target_spawn_point:
		spawn_point = target_spawn_point
		global_position = spawn_point.global_position
		
func _process(delta: float) -> void:
	handle_grab_climb_input(delta)
	handle_animation(delta)
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

func _physics_process(delta: float) -> void:
	handle_death()
	if dying:
		return
	if current_ladder:
		apply_ladder_movement(delta)
	else:
		apply_default_movement(delta)
		handle_collisions()
		
func handle_grab_climb_input(delta: float) -> void:
	if dying:
		return
	if Input.is_action_just_pressed(ability_action):
		grab_hold_timer = 0.0
		grab_input_held = true
	elif Input.is_action_pressed(ability_action) and grab_input_held:
		grab_hold_timer += delta
		if not grabbed_body and grab_hold_timer >= GRAB_HOLD_THRESHOLD:
			var closest_body = find_closest_body_in_area()
			if closest_body:
				release_ladder()
				try_grab(closest_body)
	elif Input.is_action_just_released(ability_action) and grab_input_held:
		grab_input_held = false
		if grabbed_body:
			release_grab()
		elif grab_hold_timer < GRAB_HOLD_THRESHOLD:
			if current_ladder:
				release_ladder()
			elif target_ladder:
				release_grab()
				climb_ladder()
				

func climb_ladder() -> void:
	current_ladder = target_ladder
	var local_pos_on_ladder := current_ladder.to_local(global_position)
	ladder_offset = clampf(local_pos_on_ladder.y, current_ladder.END_Y_OFFSET, current_ladder.START_Y_OFFSET)
	add_self_to_ladder_array(current_ladder)
	velocity = Vector2.ZERO
	remaining_coyote_time = LADDER_COYOTE_TIME_LENGTH

func release_ladder() -> void:
	if not current_ladder:
		return
	remove_self_from_ladder_array(current_ladder)
	current_ladder = null
	
func add_self_to_ladder_array(ladder: Ladder) -> void:
	if not ladder.players_currently_climbing.has(self):
		ladder.players_currently_climbing.append(self)
		
func remove_self_from_ladder_array(ladder: Ladder) -> void:
	ladder.players_currently_climbing.erase(self)
		
func handle_collisions() -> void:
	var last_collision := get_last_slide_collision()
	if last_collision:
		var collider := last_collision.get_collider()
		if collider is TileMapLayer:
			var tile_pos: Vector2i = last_collision.get_collider().get_coords_for_body_rid(last_collision.get_collider_rid())
			var tile_data = last_collision.get_collider().get_cell_tile_data(tile_pos)
			if tile_data:
				var is_hazard: bool = tile_data.get_custom_data("is_hazard")
				if is_hazard:
					die()
					
func die() -> void:
	release_ladder()
	release_grab()
	dying = true
	
func handle_death() -> void:
	if dying and die_animation_time_remaining <= 0:
		dying = false
		die_animation_time_remaining = DIE_ANIMATION_LENGTH
		if spawn_point:
			global_position = spawn_point.global_position
	
func handle_animation(delta: float) -> void:
	var direction: float = Input.get_axis(move_left_action, move_right_action)
	var vertical_direction: float = Input.get_axis(move_down_action, move_up_action)
	
	sprite.rotation = 0.0
	if jumping and jump_animation_time_remaining > 0 and not current_ladder:
		sprite.play("jump")
		jump_animation_time_remaining -= delta
	elif dying and die_animation_time_remaining > 0:
		sprite.play("death")
		die_animation_time_remaining -= delta
	else:		
		if current_ladder:
			sprite.play("climb_up")
			sprite.pause()
			sprite.rotation = current_ladder.rotation
			if ladder_was_upside_down_when_climbed:
				sprite.rotate(PI)
			if ladder_offset == current_ladder.START_Y_OFFSET or ladder_offset == current_ladder.END_Y_OFFSET:
				return
			if vertical_direction > 0:
				sprite.play()
			elif vertical_direction < 0:
				sprite.play_backwards()	
		elif direction != 0:
			sprite.play("move_right")
			sprite.flip_h = direction < 0
		else:
			sprite.play("idle")
			
func apply_ladder_midair_grab_movement(ladder: Ladder, delta: float) -> void:
	# TODO: if many of these lines end up staying the same as the lines in apply_ladder_movement(), put them into a new function
	var vertical_direction: float = Input.get_axis(move_down_action, move_up_action)
	var horizontal_direction: float = Input.get_axis(move_left_action, move_right_action)

	var input_direction: Vector2 = Vector2(horizontal_direction, vertical_direction)
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
		
	var ladder_direction: Vector2 = Vector2(cos(ladder.rotation), -sin(ladder.rotation))
	var ladder_direction_rotated: Vector2 = Vector2(-ladder_direction.x, -ladder_direction.y)
	
	var dot_product: float = input_direction.dot(ladder_direction_rotated)
	var projection_of_input_onto_ladder: float = dot_product / ladder_direction_rotated.length()
	
	ladder_velocity_horizontal = lerp_smooth(ladder_velocity_horizontal, -projection_of_input_onto_ladder * LADDER_MOVE_SPEED_HORIZONTAL, 0.6, delta)
	
	ladder_offset_horizontal = clampf(ladder_offset_horizontal + ladder_velocity_horizontal * delta, ladder.LEFT_OFFSET, ladder.RIGHT_OFFSET)
	
	var local_position_on_ladder := Vector2(ladder_offset_horizontal, ladder_offset)
	var global_position_on_ladder: Vector2 = ladder.to_global(local_position_on_ladder)
	position = global_position_on_ladder
	 
func apply_default_movement(delta: float) -> void:
	if grabbed_body:
		if not is_on_floor():
			if grab_joint:
				release_grab_joint()
			if grabbed_body is Ladder:
				add_self_to_ladder_array(grabbed_body)
				var local_pos_on_ladder := grabbed_body.to_local(global_position)
				ladder_offset = clampf(local_pos_on_ladder.y, grabbed_body.END_Y_OFFSET, grabbed_body.START_Y_OFFSET)
				apply_ladder_midair_grab_movement(grabbed_body, delta)
			return
		elif is_on_floor():
			if grab_joint == null:
				try_grab(grabbed_body)
	
		if grabbed_body is Ladder:
			remove_self_from_ladder_array(grabbed_body)
		
				
	apply_gravity(delta)
	handle_horizontal_movement(delta)
	handle_jump()
	move_and_slide()

func apply_ladder_movement(delta: float) -> void:
	var vertical_direction: float = Input.get_axis(move_down_action, move_up_action)
	var horizontal_direction: float = Input.get_axis(move_left_action, move_right_action)

	var input_direction: Vector2 = Vector2(horizontal_direction, vertical_direction)
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
		
	var ladder_direction: Vector2 = Vector2(cos(current_ladder.rotation), -sin(current_ladder.rotation))
	var ladder_direction_rotated: Vector2 = Vector2(-ladder_direction.y, ladder_direction.x)
	
	var dot_product: float = input_direction.dot(ladder_direction_rotated)
	var projection_of_input_onto_ladder: float = dot_product / ladder_direction_rotated.length()
	
	ladder_velocity = lerp_smooth(ladder_velocity, -projection_of_input_onto_ladder * LADDER_MOVE_SPEED, 0.6, delta)
	
	ladder_offset = clampf(ladder_offset + ladder_velocity * delta, current_ladder.END_Y_OFFSET, current_ladder.START_Y_OFFSET)
	var local_position_on_ladder := Vector2(0, ladder_offset)
	var global_position_on_ladder: Vector2 = current_ladder.to_global(local_position_on_ladder)
	position = global_position_on_ladder
	handle_jump()
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if remaining_coyote_time > 0:
			remaining_coyote_time -= delta
		velocity.y += GRAVITY * delta
		is_grounded = false
	else:
		is_grounded = true
		remaining_coyote_time = COYOTE_TIME_LENGTH
		velocity.y = 0

func handle_horizontal_movement(delta: float) -> void:
	var direction: float = Input.get_axis(move_left_action, move_right_action)
	velocity.x = lerp_smooth(velocity.x, direction * MOVE_SPEED, 0.2, delta)
	
func handle_jump() -> void:
	if Input.is_action_just_pressed(jump_action):
		jump_buffer_timer = JUMP_BUFFER_TIME
	if jumping and jump_animation_time_remaining <= 0:
		jumping = false
		jump_animation_time_remaining = JUMP_ANIMATION_LENGTH
	if can_jump():
		do_jump()

func do_jump() -> void:
	release_ladder()
	jumping = true
	velocity.y = JUMP_SPEED if not (grabbed_body is Ladder) else JUMP_SPEED / 2
	jump_buffer_timer = 0.0
	remaining_coyote_time = 0.0
	move_and_slide()

func can_jump() -> bool:
	return ((is_grounded or current_ladder) or remaining_coyote_time > 0.0) and jump_buffer_timer > 0.0

func _on_ladder_ladder_area_entered(ladder: Ladder, body: Node2D) -> void:
	if body == self:
		target_ladder = ladder

func _on_ladder_ladder_area_exited(ladder: Ladder, body: Node2D) -> void:
	if body == self and target_ladder == ladder:
		target_ladder = null
		
func find_closest_body_in_area() -> RigidBody2D:
	var closest: RigidBody2D = null
	var shortest_distance = INF
	var bodies = $GrabArea.get_overlapping_bodies()
	for body in bodies:
		if body is RigidBody2D:
			if not body.is_in_group("grabbable"):
				continue
			var dist = global_position.distance_to(body.global_position)
			if dist < shortest_distance:
				shortest_distance = dist
				closest = body
	return closest
	
func try_grab(body: RigidBody2D):
	if grab_joint: return
	grab_joint = PinJoint2D.new()
	grab_joint.node_a = self.get_path()
	grab_joint.node_b = body.get_path()
	grab_joint.position = Vector2.ZERO
	add_child(grab_joint)
	var color_rect = ColorRect.new()
	color_rect.color = Color.RED
	color_rect.size.x = 4
	color_rect.size.y = 4
	color_rect.position.x -= 2
	color_rect.position.y -= 2
	grab_joint.add_child(color_rect)
	color_rect.position = Vector2.ZERO
	grabbed_body = body

func release_grab():
	if grabbed_body:
		release_grab_joint()
		grabbed_body = null

func release_grab_joint():
	if grab_joint:
		grab_joint.queue_free()
		grab_joint = null

# TODO: probably move to a more central location
func lerp_smooth(current, target, smoothing_factor, delta, SMOOTH_DURATION = 0.01):
	var decay_rate = pow(1 - smoothing_factor, 1.0 / SMOOTH_DURATION)
	return lerp(current, target, 1.0 - pow(decay_rate, delta))

func print_if_pid(string: String, id: int):
	if player_id == id:
		print(string)
