extends Node
class_name State


signal Transitioned # signal to tell the State Machine to transition.


func State_Enter(): # runs once when the state is entered, treat it like the _ready() function.
	pass


func State_Exit(): # runs once when the state is exited.
	pass


func State_Update(_delta: float): # _process(delta) for states
	pass


func State_Physics_Update(_delta: float): # _physics_process(delta) for states
	pass
