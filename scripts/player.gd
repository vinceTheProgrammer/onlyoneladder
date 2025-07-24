extends CharacterBody2D
class_name Player

@export var player_id: int = 1
@export var player_color: Color = Color.RED;

const GRAVITY = 980.0 # pixels/sec^2
const JUMP_SPEED = -300.0
const MOVE_SPEED = 200.0
const LADDER_MOVE_SPEED = 100.0
const MASS = 5.0

@onready var move_left_action := "move_left_player%d" % player_id
@onready var move_right_action := "move_right_player%d" % player_id
@onready var move_down_action := "move_down_player%d" % player_id
@onready var move_up_action := "move_up_player%d" % player_id

@onready var jump_action := "jump_player%d" % player_id
@onready var climb_ladder_action := "interact_player%d" % player_id

@onready var grab_action := "grab_player%d" % player_id

@onready var sprite = $AnimatedSprite2D

var spawn_point: SpawnPoint

var dying: bool = false
var jumping: bool = false

const COYOTE_TIME_LENGTH = 0.2
var remaining_coyote_time: float = COYOTE_TIME_LENGTH
var can_jump: bool = true

const DIE_ANIMATION_LENGTH = 1.0
const JUMP_ANIMATION_LENGTH = 1.0
var die_animation_time_remaining: float = DIE_ANIMATION_LENGTH
var jump_animation_time_remaining: float = JUMP_ANIMATION_LENGTH

var current_ladder: Ladder
var target_ladder: Ladder

var ladder_offset := 20.0
var ladder_velocity := 0.0

var grab_joint: PinJoint2D = null
var grabbed_body: RigidBody2D = null

func _ready() -> void:
	set_spawn_point()
	
# TODO: let the level loader do this
func set_spawn_point() -> void:
	var spawn_points = get_tree().get_nodes_in_group("spawn_point")
	
	var target_spawn_point = spawn_points.filter(func(s): return s.player_id == player_id).front()
	if target_spawn_point:
		spawn_point = target_spawn_point
		global_position = spawn_point.global_position

func _physics_process(delta: float) -> void:
	handle_death()
	handle_animation(delta)
	if dying:
		return
	handle_ladder_interact()
	if current_ladder:
		apply_ladder_movement(delta)
	else:
		handle_grabbing()
		apply_default_movement(delta)
		handle_collisions()
		
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
	dying = true
	
func handle_death() -> void:
	if die_animation_time_remaining <= 0:
		dying = false
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
		jump_animation_time_remaining = JUMP_ANIMATION_LENGTH
		die_animation_time_remaining = DIE_ANIMATION_LENGTH
		if current_ladder:
			sprite.play("climb_up")
			sprite.pause()
			sprite.rotation = current_ladder.rotation
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
	 
func apply_default_movement(delta: float) -> void:
	apply_gravity(delta)
	handle_horizontal_movement()
	handle_jump()
	move_and_slide()

func apply_ladder_movement(delta: float) -> void:
	handle_ladder_vertical_movement()
	ladder_offset = clampf(ladder_offset + ladder_velocity * delta, current_ladder.END_Y_OFFSET, current_ladder.START_Y_OFFSET)
	var local_position_on_ladder := Vector2(0, ladder_offset)
	var global_position_on_ladder: Vector2 = current_ladder.to_global(local_position_on_ladder)
	position = global_position_on_ladder
	
func handle_ladder_vertical_movement() -> void:
	var direction: float = Input.get_axis(move_down_action, move_up_action)
	ladder_velocity = lerpf(ladder_velocity, -direction * LADDER_MOVE_SPEED, 0.6)
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		if can_jump:
			remaining_coyote_time -= delta
		velocity.y += GRAVITY * delta
	else:
		can_jump = true
		remaining_coyote_time = COYOTE_TIME_LENGTH
		velocity.y = 0

func handle_horizontal_movement() -> void:
	var direction: float = Input.get_axis(move_left_action, move_right_action)
	velocity.x = lerpf(velocity.x, direction * MOVE_SPEED, 0.2)
	
func handle_jump() -> void:
	if remaining_coyote_time <= 0:
		can_jump = false
	if Input.is_action_just_pressed(jump_action):
		if not can_jump:
			return
		can_jump = false
		jumping = true
		velocity.y = JUMP_SPEED
	if jump_animation_time_remaining <= 0:
		jumping = false
		
func handle_ladder_interact():
	if Input.is_action_just_pressed(climb_ladder_action):
		if current_ladder:
			current_ladder.players_currently_climbing.erase(self)
			current_ladder = null
		elif target_ladder:
			current_ladder = target_ladder
			var local_pos_on_ladder := current_ladder.to_local(global_position)
			ladder_offset = clampf(local_pos_on_ladder.y, current_ladder.END_Y_OFFSET, current_ladder.START_Y_OFFSET)
			if not current_ladder.players_currently_climbing.has(self):
				current_ladder.players_currently_climbing.append(self)

func _on_ladder_ladder_area_entered(ladder: Ladder, body: Node2D) -> void:
	if body == self:
		target_ladder = ladder

func _on_ladder_ladder_area_exited(ladder: Ladder, body: Node2D) -> void:
	if body == self and target_ladder == ladder:
		target_ladder = null
		
func handle_grabbing() -> void:
	if Input.is_action_just_pressed(grab_action):
		if not grabbed_body:
			var closest_body = find_closest_body_in_area()
			if closest_body:
				try_grab(closest_body, global_position)
		else:
			release_grab()
		
		
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
	
func try_grab(body: RigidBody2D, grab_pos: Vector2):
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
	if grab_joint:
		grab_joint.queue_free()
		grab_joint = null
		grabbed_body = null
