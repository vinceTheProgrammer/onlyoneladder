extends RigidBody2D
class_name Ladder

signal ladder_area_entered(ladder: RigidBody2D, body: Node2D)
signal ladder_area_exited(ladder: RigidBody2D, body: Node2D)

const START_Y_OFFSET = 63
const END_Y_OFFSET = -63

var players_currently_climbing: Array[Player] = []

func _physics_process(delta: float) -> void:
	update_center_of_mass()
	queue_redraw()
	print(players_currently_climbing)
	
func update_center_of_mass() -> void:
	var total_weight := 0.0
	var weighted_sum := Vector2.ZERO
	
	weighted_sum += Vector2.ZERO * self.mass
	total_weight += self.mass
	
	for player in players_currently_climbing:
		var local_pos = self.to_local(player.global_position)
		var weight = player.MASS
		weighted_sum += local_pos * weight
		total_weight += weight
	
	if total_weight > 0:
		var new_center_of_mass = weighted_sum / total_weight
		if new_center_of_mass != self.center_of_mass:
			self.sleeping = false
		self.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
		self.center_of_mass = new_center_of_mass
	else:
		self.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_AUTO
		
func _draw() -> void:
	draw_circle(self.center_of_mass, 20, Color.CORAL)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("ladder_area_entered", self, body)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("ladder_area_exited", self, body)
