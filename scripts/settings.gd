extends Node

var volume := 1.0
var sound_on := true


func set_volume(v: float) -> void:
	volume = v
	set_sound_on(true)


func set_sound_on(on: bool) -> void:
	sound_on = on
	AudioServer.set_bus_volume_db(0, linear_to_db(volume))
	AudioServer.set_bus_mute(0, not on)
