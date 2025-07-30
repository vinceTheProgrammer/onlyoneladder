extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



func _ready() -> void:
	animated_sprite_2d.play("default")


func _on_body_entered(body) -> void:
		if body is PlayerV2:
			body.velocity = Vector2.ZERO
			body.sm.current_state.Transitioned.emit(body.sm.current_state, "Death")
