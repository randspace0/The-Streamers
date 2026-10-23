class_name Building
extends RefCounted
# Port of Building.cs. Unity's capacities/durations were prefab values, so these are guesses.

var cell: Vector2i
var hot := 50.0
var cold := 50.0
var mood := 100.0
var hot_cap := 100.0
var cold_cap := 100.0
var mood_cap := 100.0
var uses_hot := false
var connected := false
var min_change := 5.0
var max_change := 10.0
var _timer: float


func _init(c: Vector2i) -> void:
	cell = c
	_timer = randf_range(min_change, max_change)


func update(delta: float, pipe_hot: bool) -> void:
	if _timer > 0.0:
		_timer -= delta
	else:
		uses_hot = not uses_hot
		_timer = randf_range(min_change, max_change)

	if uses_hot:
		hot -= 2.0 * delta
		if hot <= 0.0:
			mood -= 5.0 * delta
	else:
		cold -= 2.0 * delta
		if cold <= 0.0:
			mood -= 5.0 * delta

	if connected:
		if pipe_hot:
			hot += 5.0 * delta
		else:
			cold += 5.0 * delta

	hot = clampf(hot, 0.0, hot_cap)
	cold = clampf(cold, 0.0, cold_cap)
	mood = clampf(mood, 0.0, mood_cap)
