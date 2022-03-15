extends Gift

var send_msg: bool

onready var SettingsNode = get_node("/root/ReadWriteSettings")
# Called when the node enters the scene tree for the first time.
func _ready():
	send_msg = true
	reload_configuration()

func clear_channels():
	var channel_keys = channels.keys()
	for i in channel_keys:
		leave_channel(i)

func init_auth(user, password):
	authenticate_oauth(user, password)
	
func show_commands():
	var str_commands = "Comandos disponibles: " + str(command_prefixes) + PoolStringArray(commands.keys().duplicate()).join(", " + str(command_prefixes))
	chat_main_channel(str_commands)
	
func chat_main_channel(msg: String):
	print_debug(msg)
	if not send_msg:
		print_debug("Messages to twitch are disabled")
		return

	if channels.empty():
		return
	
	chat(msg, channels.keys()[0])


func reload_configuration():
	var cmd_default:Dictionary = ProjectSettings.get_setting("global/cmd_default")
	var settings = SettingsNode.current_settings.get("commands", {})
	
	for i in cmd_default.keys():
		purge_command(i)
	
	for cmd_name in cmd_default.keys():
		var method_ref = cmd_default[cmd_name]["method_ref"]
		var min_arg = cmd_default[cmd_name]["min_arg"]
		var max_arg = cmd_default[cmd_name]["max_arg"]
		var default_flag = _get_flag_from_string(cmd_default[cmd_name]["flag"])
		if(settings.has(cmd_name)):
			add_command_with_settings(cmd_name, method_ref, min_arg, max_arg, settings[cmd_name])
		else:
			add_command(cmd_name, get_parent(), method_ref, min_arg, max_arg, default_flag)

func add_command_with_settings(cmd_name: String, method_ref:String, min_args:int, max_args:int, settings):
	add_command(cmd_name, get_parent(), method_ref, min_args, max_args, _get_flag_from_string(settings["flag"]))
	var alias = settings["alias"].split(",",false)
	for i in alias:
		var alias_stripped = i.strip_edges()
		if(alias_stripped != ""):
			add_alias(cmd_name, alias_stripped)

func _on_ModifyCommandsDialog_popup_hide():
	reload_configuration()

func _get_flag_from_string(flag: String) -> int:
	match(flag):
		"EVERYONE":
			return PermissionFlag.EVERYONE
		"SUBSCRIBER":
			return PermissionFlag.MOD_STREAMER + PermissionFlag.SUB
		"MODERATOR":
			return PermissionFlag.MOD_STREAMER
		"STREAMER":
			return PermissionFlag.STREAMER
		_:
			return PermissionFlag.STREAMER
	
	
	
	
	
	
	
	
	
	
	
	
	
	
