extends WindowDialog

signal ban_player(player_str)

onready var playerBan = $MarginContainer/VBoxContainer/HBoxContainer/LineEdit
onready var acceptButton = $MarginContainer/VBoxContainer/Button

func _ready():
	var stripped_text:String = playerBan.text.strip_edges()
	acceptButton.disabled = not (stripped_text != "" and stripped_text.split(" ", false, 1).size() == 1)

func _on_Button_button_up():
	emit_signal("ban_player", playerBan.text.strip_edges())
	visible = false


func _on_LineEdit_text_changed(new_text):
	var stripped_text:String = new_text.strip_edges()
	acceptButton.disabled = not (stripped_text != "" and stripped_text.split(" ", false, 1).size() == 1)
