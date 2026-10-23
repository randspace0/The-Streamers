extends SceneTree
# godot --headless --path . -s tests/test_piping.gd

var _failed := false


func _check(ok: bool, what: String) -> void:
	if not ok:
		_failed = true
		printerr("FAIL: ", what)


func _init() -> void:
	var p := Piping.from_rows(Levels.ONE, Levels.ORIGIN)
	var building := Vector2i(2, -3)
	var heater := Vector2i(-1, -1)
	var t := Vector2i(-1, -3)
	var l := Vector2i(-3, 1)

	_check(p.pdam == Vector2i(-3, 2), "pdam cell")
	_check(p.building_cells == [building], "building cell")
	_check(p.watered.has(building) and p.tiles[building].hot, "start: building gets hot water via the heater")
	_check(p.tiles[Vector2i(-1, 0)].hot == false, "pdam side of the heater stays cold")

	_check(not p.rotate_at(heater), "heater is fixed")
	_check(not p.rotate_at(Vector2i(-4, 0)), "non-interactable pipe is fixed")
	_check(not p.rotate_at(Vector2i(0, 2)), "empty cell is not rotatable")

	_check(p.rotate_at(t), "T rotates")
	_check(not p.watered.has(building), "T turned away: building dry")

	for i in 3:
		p.rotate_at(l)
	_check(p.watered.has(building) and not p.tiles[building].hot, "L turned left: building gets cold water via the long loop")

	quit(1 if _failed else 0)
