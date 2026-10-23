extends Node
# Autoload, so sounds survive scene changes (replaces AudioSafeScreenTransition)


func play(sound: String) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = load("res://audio/%s.wav" % sound)
	p.finished.connect(p.queue_free)
	add_child(p)
	p.play()
