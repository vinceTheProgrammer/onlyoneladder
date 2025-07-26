extends Node


@export var Init_State : State

var current_state : State
var states : Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
	if Init_State:
		Init_State.State_Enter()
		current_state = Init_State

func _process(delta: float) -> void:
	if current_state:
		current_state.State_Update(delta)



func _physics_process(delta: float) -> void:
	if current_state:
		current_state.State_Physics_Update(delta)



func on_child_transition(state, newstate):
	if state != current_state:
		return
	
	var new_state = states.get(newstate.to_lower())
	if !new_state:
		return
	
	if current_state:
		current_state.State_Exit()
	
	new_state.State_Enter()
	
	current_state = new_state
