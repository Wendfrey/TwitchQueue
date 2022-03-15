extends WindowDialog

signal start_session(user, password, channel)

const AUTH_STRING = "{key}={value}"

onready var userLineEdit = $VBoxContainer/UserInput
onready var passwordLineEdit = $VBoxContainer/PasswordInput
onready var channelLineEdit = $VBoxContainer/CanalInput

onready var connectButton = $VBoxContainer/ConnectButton
onready var saveUserDataToggle = $VBoxContainer/SaveDataToggle

onready var settingsNode = get_node("/root/ReadWriteSettings")


func _on_ConnectButton_button_up():
	var user_text: String = userLineEdit.text.strip_edges()
	var password_text: String = passwordLineEdit.text.strip_edges()
	var channel_text: String = channelLineEdit.text.strip_edges()
	
	visible = false
	
	if(saveUserDataToggle.pressed):
		write_file_data(user_text, password_text, channel_text)
	
	emit_signal("start_session", user_text, password_text, channel_text)
	

func checkEnableButton():
	connectButton.disabled = (userLineEdit.text == "" || passwordLineEdit.text == "" || channelLineEdit.text == "")



func _on_AuthDialog_about_to_show():
	
	var settings = settingsNode.current_settings.duplicate()
	
	if(settings.has("user")):
		userLineEdit.text = settings["user"]
	
	if(settings.has("password")):
		passwordLineEdit.text = settings["password"]
	
	if(settings.has("channel")):
		channelLineEdit.text = settings["channel"]
		
func read_auth_file() -> Dictionary:
	var authFile = File.new()
	var error = authFile.open(ProjectSettings.get_setting("global/conf_filename"), File.READ)
	
	if(error):
		print("An unexpected error has ocurred: %s" % str(error))
		return {}
	var data_readed = {}
	while not authFile.eof_reached():
		var line = authFile.get_line().split("=", false, 1)
		if(line.size() == 0):
			continue
		
		var key = line[0].strip_edges()
		var value = line[1].strip_edges()
		match(key):
			"user", "password", "channel":
				data_readed[key] = value
	return data_readed

func write_file_data(user, password, channel):
	settingsNode.current_settings["user"] = user
	settingsNode.current_settings["password"] = password
	settingsNode.current_settings["channel"] = channel
