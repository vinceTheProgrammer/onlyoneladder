extends Node

# Use this method for frame independent lerp. Not necessary inside of _physics_process because delta is expected to be constant
static func lerp_smooth(current, target, smoothing_factor, delta, SMOOTH_DURATION = 0.01):
	var decay_rate = pow(1 - smoothing_factor, 1.0 / SMOOTH_DURATION)
	return lerp(current, target, 1.0 - pow(decay_rate, delta))
