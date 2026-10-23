extends Node2D

var _board: Board
var _score: Label


func _ready() -> void:
	_board = Board.new()
	add_child(_board)
	_board.load_level(Levels.ONE, Levels.ORIGIN)

	_score = Label.new()
	var hint := Label.new()
	hint.text = "Space: toggle underground / Click: rotate pipe"
	var back := UI.button("MainMenu-Back", func() -> void: get_tree().change_scene_to_file("res://scenes/level_select.tscn"))

	var hud := CanvasLayer.new()
	var row := HBoxContainer.new()
	row.add_child(back)
	row.add_child(_score)
	row.add_child(hint)
	hud.add_child(row)
	add_child(hud)


func _process(_delta: float) -> void:
	_score.text = "%s %0.1f%%" % [I18n.t("Game-Score:"), _board.mean_mood()]
