extends Control

var _menu: CenterContainer
var _settings: CenterContainer


func _ready() -> void:
	_menu = UI.page([
		UI.button("MainMenu-Start", func() -> void: get_tree().change_scene_to_file("res://scenes/level_select.tscn")),
		UI.button("MainMenu-Settings", func() -> void: _show_settings(true)),
	])

	var volume := HSlider.new()
	volume.max_value = 1.0
	volume.step = 0.01
	volume.value = Settings.volume
	volume.custom_minimum_size = Vector2(240, 24)

	var mute := CheckButton.new()
	mute.text = I18n.t("MainMenu-Mute")
	mute.button_pressed = not Settings.sound_on

	volume.value_changed.connect(func(v: float) -> void:
		Settings.set_volume(v)
		mute.set_pressed_no_signal(false))
	mute.toggled.connect(func(on: bool) -> void: Settings.set_sound_on(not on))

	var volume_label := Label.new()
	volume_label.text = I18n.t("MainMenu-Volume")

	_settings = UI.page([
		volume_label,
		volume,
		mute,
		UI.button("CurrentLanguage", func() -> void:
			I18n.next_locale()
			get_tree().reload_current_scene()),
		UI.button("MainMenu-Back", func() -> void: _show_settings(false)),
	])
	_show_settings(false)
	add_child(_menu)
	add_child(_settings)


func _show_settings(on: bool) -> void:
	_settings.visible = on
	_menu.visible = not on
