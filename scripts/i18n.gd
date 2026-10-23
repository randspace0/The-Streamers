extends Node

const LOCALES := ["en-US", "id-ID"]

var locale: String = LOCALES[0]
var _strings := {}


func _ready() -> void:
	set_locale(locale)


func set_locale(l: String) -> void:
	locale = l
	var f := FileAccess.open("res://locales/%s.json" % l, FileAccess.READ)
	# Unity-exported JSON may carry a BOM, which JSON.parse_string rejects
	_strings = JSON.parse_string(f.get_as_text().trim_prefix("﻿"))


func next_locale() -> void:
	set_locale(LOCALES[(LOCALES.find(locale) + 1) % LOCALES.size()])


func t(key: String) -> String:
	return _strings.get(key, key)
