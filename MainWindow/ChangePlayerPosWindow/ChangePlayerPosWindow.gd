extends WindowDialog

signal change_player_position(playername, position)

onready var playerLabel = $MarginContainer/VBoxContainer/PlayerLabel
onready var positionLineEdit = $MarginContainer/VBoxContainer/HBoxContainer/PositionEditLabel
onready var acceptButton = $MarginContainer/VBoxContainer/AceptarButton

var player_name
var current_pos

func set_data(_playername: String, _current_position: int):
	playerLabel.text = "Jugador " + _playername
	positionLineEdit.text = str(_current_position)
	player_name = _playername
	current_pos = _current_position
	acceptButton.disabled =  not positionLineEdit.text.is_valid_integer()

func _on_AceptarButton_button_up():
	visible = false
	var new_position = int(positionLineEdit.text)
	if(current_pos != new_position):
		emit_signal("change_player_position", player_name, new_position)

func _on_PositionEditLabel_text_changed(new_text):
	acceptButton.disabled =  not new_text.is_valid_integer()
