class_name UI


static func button(key: String, on_press: Callable) -> Button:
	var b := Button.new()
	b.text = I18n.t(key)
	b.custom_minimum_size = Vector2(240, 48)
	b.pressed.connect(func() -> void:
		Sfx.play("button_clicked")
		on_press.call())
	return b


static func page(children: Array) -> CenterContainer:
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	center.add_child(box)
	for c in children:
		box.add_child(c)
	return center
