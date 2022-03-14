extends Control
class_name PlayerLabel

signal option_selected(player_str, id_action)

func _ready():
	$HBoxContainer/MenuButton.get_popup().connect("id_pressed", self, "on_menu_button_popup_id_pressed")
	
func get_menu_button():
	return $HBoxContainer/MenuButton
	
func on_menu_button_popup_id_pressed(id):
	emit_signal("option_selected", $HBoxContainer/MenuButton.text, id)

func set_data(position: String, player_name: String):
	$HBoxContainer/MenuButton.text = player_name
	$HBoxContainer/Label.text = position

func _input(event):
	event is InputEventMouse


func _on_PlayerLabel_mouse_entered():
	$Background.color.a = 0.2


func _on_PlayerLabel_mouse_exited():
	$Background.color.a = 0.0
