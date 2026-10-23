class_name Piping
extends RefCounted
# Port of Piping.cs + PipeStraight/L/T/Cross.cs: one Pipe type, open sides come from SHAPES[kind][state].

# Unity cell axes: y+ is UP (the grid is isometric, so this is not screen-up)
const UP := Vector2i(0, 1)
const RIGHT := Vector2i(1, 0)
const DOWN := Vector2i(0, -1)
const LEFT := Vector2i(-1, 0)

const SHAPES := {
	"S": [[UP, DOWN], [RIGHT, LEFT]],
	"L": [[UP, RIGHT], [DOWN, RIGHT], [DOWN, LEFT], [UP, LEFT]],
	"T": [[UP, RIGHT, DOWN], [RIGHT, DOWN, LEFT], [DOWN, LEFT, UP], [LEFT, UP, RIGHT]],
	"X": [[UP, RIGHT, DOWN, LEFT]],
}
const DIRS := {"U": UP, "R": RIGHT, "D": DOWN, "L": LEFT}


class Pipe:
	var kind: String
	var state := 0
	var hot := false
	var heat_dir := Vector2i.ZERO  # heater: only direction its hot water leaves through
	var fixed := false

	func sides() -> Array:
		return Piping.SHAPES[kind][state]

	func rotate_pipe() -> void:
		state = (state + 1) % Piping.SHAPES[kind].size()


var tiles := {}  # Vector2i -> Pipe
var pdam := Vector2i.ZERO
var building_cells: Array[Vector2i] = []
var watered := {}  # cells reachable from the pdam
var size := Vector2i.ZERO
var origin := Vector2i.ZERO


# Level rows are space-separated tokens, one row per cell y starting at `origin`, x starting at origin.x:
#   .       empty
#   S1 L2 T0 X   pipe kind + start state; fixed unless suffixed with * (rotatable)
#   HD      fixed heater pushing hot water Down (HU/HR/HL likewise)
#   P<pipe> pdam on that pipe (e.g. PS0); B<pipe> building inlet on that pipe
static func from_rows(rows: Array, origin := Vector2i.ZERO) -> Piping:
	var p := Piping.new()
	p.origin = origin
	for y in rows.size():
		var tokens: PackedStringArray = rows[y].split(" ", false)
		p.size = Vector2i(maxi(p.size.x, tokens.size()), rows.size())
		for x in tokens.size():
			p._place(origin + Vector2i(x, y), tokens[x])
	p.update()
	return p


func _place(pos: Vector2i, token: String) -> void:
	if token == ".":
		return
	var pipe := Pipe.new()
	if token[0] == "P":
		pdam = pos
		token = token.substr(1)
	elif token[0] == "B":
		building_cells.append(pos)
		token = token.substr(1)
	if token[0] == "H":
		pipe.kind = "S"
		pipe.heat_dir = DIRS[token[1]]
		pipe.state = 0 if pipe.heat_dir.x == 0 else 1
	else:
		pipe.kind = token[0]
		pipe.state = int(token.substr(1).trim_suffix("*"))
	pipe.fixed = pipe.kind == "X" or pipe.heat_dir != Vector2i.ZERO or not token.ends_with("*")
	tiles[pos] = pipe


# Both pipes must open towards each other (Unity checked the pair in both directions)
func linked(a: Vector2i, b: Vector2i) -> bool:
	var pa: Pipe = tiles.get(a)
	var pb: Pipe = tiles.get(b)
	return pa != null and pb != null and (b - a) in pa.sides() and (a - b) in pb.sides()


func _flood(start: Vector2i, heated: bool) -> Dictionary:
	var seen := {start: true}
	var queue := [start]
	while not queue.is_empty():
		var pos: Vector2i = queue.pop_front()
		var pipe: Pipe = tiles[pos]
		for d in pipe.sides():
			if heated and pipe.heat_dir != Vector2i.ZERO and d != pipe.heat_dir:
				continue
			var next: Vector2i = pos + d
			if not seen.has(next) and linked(pos, next):
				seen[next] = true
				queue.append(next)
	return seen


func update() -> void:
	for pipe in tiles.values():
		pipe.hot = false
	for pos in tiles:
		if tiles[pos].heat_dir != Vector2i.ZERO:
			for cell in _flood(pos, true):
				tiles[cell].hot = true
	watered = _flood(pdam, false)


# Returns false when nothing was rotated (empty or fixed tile)
func rotate_at(pos: Vector2i) -> bool:
	var pipe: Pipe = tiles.get(pos)
	if pipe == null or pipe.fixed:
		return false
	pipe.rotate_pipe()
	update()
	return true
