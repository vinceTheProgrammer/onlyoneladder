extends Area2D

# copied part of this code from kill_zone.gd but it doesn't seem to do anything
# TODO: get this to work
func _on_body_entered(body: Node2D) -> void:
	if body is PlayerV2:
		body.velocity = Vector2.ZERO
		body.sm.current_state.Transitioned.emit(body.sm.current_state, "Death")
