class_name Board
extends Node2D
# Draws both layers (Space toggles) and runs the building simulation.
# Isometric layout copied from the Unity Grid: cell size (1, 0.5), sprites 100 px per unit.

const ZOOM := 1.5
const PX := 100.0 * ZOOM
const BG_UNDER := Color("3b2f26")
const BG_GROUND := Color("bfe3f5")
const HOT := Color("f97316")
const COLD := Color("3b82f6")

# Sprite lists per pipe kind, indexed by state (same order as the Unity prefabs)
const SPRITES := {
	"S": {
		"cold": ["pipa_horizontal", "pipa_1"],
		"hot": ["panas_horizontal", "panas_vertikal"],
		"heater": ["heater_1", "heater_2"],
	},
	"L": {
		"cold": ["1pipa_belok_4", "pipa_belok_3", "1pipa_belok_1", "1pipa_belok_2"],
		"hot": ["panas_belok_3", "panas_belok_1", "panas_belok_4", "panas_beok_2"],
	},
	"T": {
		"cold": ["1pipa_tri_1", "pipa_tri_3", "4pipa_tri_2", "pipa_tri_4"],
		"hot": ["panas_tri_2", "panas_tri_1"],
	},
	"X": {"cold": ["1pipa_x"]},
}

const LAND := preload("res://art/pipes/land.png")
const BUILDING := preload("res://art/building1.png")
const PDAM := preload("res://art/pdam.png")
const BUBBLE_FIRE := preload("res://art/bubble_fire.png")
const BUBBLE_ICE := preload("res://art/bubble_ice.png")
const FACES := [
	preload("res://art/smiley_face.png"),
	preload("res://art/sad_face.png"),
	preload("res://art/mad_face.png"),
]

var piping: Piping
var buildings := {}  # Vector2i -> Building
var underground := false
var _order: Array[Vector2i] = []  # far cells first
var _textures := {}


func load_level(rows: Array, origin: Vector2i) -> void:
	piping = Piping.from_rows(rows, origin)
	for cell in piping.building_cells:
		buildings[cell] = Building.new(cell)
	_order.assign(piping.tiles.keys())
	_order.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x + a.y > b.x + b.y)

	var bounds := Rect2(_cell_pos(_order[0]), Vector2.ZERO)
	for cell in _order:
		bounds = bounds.expand(_cell_pos(cell))
	position = get_viewport_rect().size / 2.0 - bounds.get_center()


func mean_mood() -> float:
	var total := 0.0
	for b in buildings.values():
		total += b.mood
	return total / buildings.size()


func _process(delta: float) -> void:
	for b in buildings.values():
		b.connected = piping.watered.has(b.cell)
		b.update(delta, piping.tiles[b.cell].hot)
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		underground = not underground
		Sfx.play("layer_toggle" if underground else "layer_toggle_counter")
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and underground:
		var cell := _pos_cell(get_local_mouse_position())
		if piping.tiles.has(cell):
			Sfx.play("pipe_rotate" if piping.rotate_at(cell) else "pipe_blocked_forbidden")


# Unity isometric grid: world x = (cx - cy) / 2, y = (cx + cy + 1) / 4 (y up); screen y is flipped
func _cell_pos(cell: Vector2i) -> Vector2:
	return Vector2(cell.x - cell.y, -(cell.x + cell.y + 1) * 0.5) * 0.5 * PX


func _pos_cell(p: Vector2) -> Vector2i:
	var x := p.x / PX
	var y := -p.y / PX
	return Vector2i(roundi((2.0 * x + 4.0 * y - 1.0) / 2.0), roundi((4.0 * y - 1.0 - 2.0 * x) / 2.0))


func _draw() -> void:
	draw_rect(Rect2(-4000, -4000, 8000, 8000), BG_UNDER if underground else BG_GROUND)
	for cell in _order:
		if underground:
			_blit(_pipe_texture(piping.tiles[cell]), _cell_pos(cell), 0.45)
		else:
			_blit(LAND, _cell_pos(cell), 0.5)
	if not underground:
		_draw_above_ground()


func _draw_above_ground() -> void:
	for cell in _order:
		if cell == piping.pdam:
			_blit(PDAM, _cell_pos(cell) + Vector2(0, -0.1 * PX), 0.5)
		if buildings.has(cell):
			_draw_building(buildings[cell])


func _draw_building(b: Building) -> void:
	var base := _cell_pos(b.cell)
	_blit(BUILDING, base, 0.15)
	var top := base + Vector2(-30, -102.0 * ZOOM - 34)
	_bar(top, b.hot / b.hot_cap, HOT)
	_bar(top + Vector2(0, 8), b.cold / b.cold_cap, COLD)
	_bar(top + Vector2(0, 16), b.mood / b.mood_cap, Color("22c55e"))
	draw_texture_rect(BUBBLE_FIRE if b.uses_hot else BUBBLE_ICE, Rect2(top + Vector2(-36, -4), Vector2(32, 32)), false)
	var m: float = b.mood / b.mood_cap
	draw_texture_rect(FACES[0 if m > 0.66 else 1 if m > 0.33 else 2], Rect2(top + Vector2(66, -4), Vector2(32, 32)), false)


func _pipe_texture(pipe: Piping.Pipe) -> Texture2D:
	var sprites: Dictionary = SPRITES[pipe.kind]
	var names: Array = sprites["cold"]
	if pipe.heat_dir != Vector2i.ZERO:
		names = sprites["heater"]
	elif pipe.hot and sprites.has("hot") and pipe.state < sprites["hot"].size():
		# Unity indexed hotSprites out of range for T states 2-3; those stay cold-looking here
		names = sprites["hot"]
	var n: String = names[pipe.state]
	if not _textures.has(n):
		_textures[n] = load("res://art/pipes/%s.png" % n)
	return _textures[n]


# pivot_y is the Unity sprite pivot measured from the bottom
func _blit(tex: Texture2D, at: Vector2, pivot_y: float) -> void:
	var s := tex.get_size() * ZOOM
	draw_texture_rect(tex, Rect2(at + Vector2(-s.x / 2.0, -s.y * (1.0 - pivot_y)), s), false)


func _bar(pos: Vector2, frac: float, color: Color) -> void:
	draw_rect(Rect2(pos, Vector2(60, 6)), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(pos, Vector2(60 * clampf(frac, 0.0, 1.0), 6)), color)
