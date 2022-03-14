extends PanelContainer
class_name BannedPlayerLabel
signal option_selected(player_str, id)
# Called when the node enters the scene tree for the first time.
onready var bannedMenuButton = $BannedPlayerButton
onready var background = $Background

func _ready():
	bannedMenuButton.get_popup().connect("id_pressed", self, "_on_popup_id_pressed")

func _on_popup_id_pressed(id_pressed):
	emit_signal("option_selected", bannedMenuButton.text, id_pressed)


func _on_mouse_entered():
	background.color.a = 0.2


func _on_mouse_exited():
	background.color.a = 0.0
	
func _set_text(_text: String):
	bannedMenuButton.text = _text
