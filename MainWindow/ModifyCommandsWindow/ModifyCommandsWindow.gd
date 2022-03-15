extends WindowDialog

onready var commandSelector = $MarginContainer/VBoxContainer/CommandSelector

onready var commandDescription = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/CommandDescrLabel
onready var flagSelector = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer/PermFlagOption
onready var aliasEditor = $MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/VBoxContainer2/AliasEdit

onready var aplicarButton = $MarginContainer/VBoxContainer/HBoxContainer/AplicarButton
onready var cancelarButton = $MarginContainer/VBoxContainer/HBoxContainer/CancelarButton
onready var defectoButton = $MarginContainer/VBoxContainer/HBoxContainer/DefectoButton

var options_data
var last_command_index = 0

onready var SettingsNode = get_node("/root/ReadWriteSettings")

const commands = [
	"queue_clear",
	"queue_join",
	"queue_exit",
	"queue_rmp",
	"queue_next",
	"queue_ban",
	"queue_unban",
	"queue_commands",
	"queue_position",
	"queue_top10"
]

const command_descr = [
	"Elimina a todos los jugadores de la cola",
	"Únete a la cola",
	"Salte de la cola",
	"Elimina a un jugador de la cola",
	"Coge al siguiente jugador y avanza la cola",
	"Veta a un jugador",
	"Desveta a un jugador",
	"Muestra los commandos",
	"Cambia a un jugador de posición en la cola",
	"Muestra los 10 primeros de la cola"
]

func _ready():
	options_data = SettingsNode.current_settings.get("commands", {})
	if !options_data:
		options_data = {}
	
	_load_option(last_command_index)
	aplicarButton.disabled = true

func _on_CommandSelector_item_selected(index):
	if(index >= commands.size()):
		return
#Store data
	if(last_command_index > -1):
		_save_option(commands[last_command_index], _get_flags_for_index(flagSelector.selected), aliasEditor.text.strip_edges())
		aplicarButton.disabled = (options_data.keys().size() == 0)

#Show data
	if(index > -1):
		_load_option(index)
		last_command_index = index

func _get_flags_for_index(index) -> String:
	match(index):
		0:
			return "EVERYONE"
		1:
			return "SUBSCRIBER"
		2:
			return "MODERATOR"
		3:
			return "STREAMER"
		_:
			return "EVERYONE"

func _get_index_for_flags(flag) -> int:
	var sub_mod_streamer = Gift.PermissionFlag.SUB + Gift.PermissionFlag.MOD_STREAMER
	match(flag):
		"EVERYONE":
			return 0
		"SUBSCRIBER":
			return 1
		"MODERATOR":
			return 2
		"STREAMER":
			return 3
		_:
			return 0
			
func _save_option(_cmd, _flag, _alias):
	var default_cmd = ProjectSettings.get_setting("global/cmd_default")[_cmd]
	if(_alias == "" and default_cmd["flag"] == _flag):
		options_data.erase(_cmd)
	elif options_data.has(_cmd):
		options_data[_cmd]["flag"] = _flag
		options_data[_cmd]["alias"] = _alias
	else:
		options_data[_cmd] = {"flag": _flag, "alias": _alias}

func _load_option(_index):
	var _cmd = commands[_index]
	var default_cmd = ProjectSettings.get_setting("global/cmd_default")[_cmd]
	if(options_data.has(_cmd)):
		flagSelector.select(_get_index_for_flags(options_data[_cmd]["flag"]))
		aliasEditor.text = options_data[_cmd]["alias"]
	else:
		flagSelector.select(_get_index_for_flags(default_cmd["flag"]))
		aliasEditor.text = ""
	commandDescription.text = command_descr[_index]

func _on_DefectoButton_button_up():
	if(SettingsNode.current_settings.has("commands")):
		SettingsNode.current_settings.erase("commands")
	visible = false


func _on_AplicarButton_button_up():
	_save_option(commands[last_command_index], _get_flags_for_index(flagSelector.selected), aliasEditor.text.strip_edges())
	if(options_data.keys().size() > 0):
		SettingsNode.current_settings["commands"] = options_data
	elif (SettingsNode.current_settings.has("commands")):
		SettingsNode.current_settings.erase("commands")
	visible = false


func _on_CancelarButton_button_up():
	visible = false


func _on_PermFlagOption_item_selected(index):
	_save_option(commands[last_command_index], _get_flags_for_index(index), aliasEditor.text.strip_edges())
	aplicarButton.disabled = (options_data.keys().size() == 0)


func _on_AliasEdit_text_changed(new_text):
	_save_option(commands[last_command_index], _get_flags_for_index(flagSelector.selected), aliasEditor.text.strip_edges())
	aplicarButton.disabled = (options_data.keys().size() == 0 and aliasEditor.text.strip_edges() == "")
