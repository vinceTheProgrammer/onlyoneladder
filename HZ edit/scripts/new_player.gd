
# master code for properties and variables, control the character
# in the state machine code instead.

extends CharacterBody2D
class_name PlayerV2

@export_category("Player Properties")

@export var player_id : int = 1
@export var speed : int = 200
@export var jump_force : int = 400
@export var coyote_time : float = 0.2
@export var gravity : int = 980
@export var cursor_color : Color


@export_category("State Objects") # children that need to be manipulated by the state machine 

@export var anims: AnimatedSprite2D
@export var player_cursor: Polygon2D


@onready var move_left_action := "move_left_player%d" % player_id
@onready var move_right_action := "move_right_player%d" % player_id
@onready var move_down_action := "move_down_player%d" % player_id
@onready var move_up_action := "move_up_player%d" % player_id
@onready var jump_action := "jump_player%d" % player_id
@onready var ability_action := "grab_player%d" % player_id


func _ready() -> void:
	match player_id:
		1:
			cursor_color = Color.SKY_BLUE
		2:
			cursor_color = Color.LAWN_GREEN
	player_cursor.color = cursor_color




func _physics_process(delta: float) -> void:
	move_and_slide()
