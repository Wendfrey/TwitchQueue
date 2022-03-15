extends Control

#Main class, contains all the commands functionality & GIFT responses
#	To see user input for login check $AuthDialog
#	To see user input for modifing commands check $ModifyCommandsDialog
#	To see setting read/write check res://MainWindow/ReadWriteSettings.gd

#Default name used when a command is executed from this app
const BOT_NAME = "BotApp"

onready var gift = $Gift
onready var errorDialog = $ErrorDialog
onready var retryDialog = $ConfirmationDialog
onready var authDialog = $AuthDialog
onready var commandDialog = $ModifyCommandsDialog
onready var changePlayerPosWindow = $ChangePlayerPosWindow
onready var banPlayerWindow = $BanPlayerWindow

#Cola views
onready var playerScrollContainer = $Panel/TabContainer/Cola/PlayerScrollContainer
onready var currentPlayerText = $Panel/TabContainer/Cola/CurrentPlayerText

#Banned views
onready var bannedBoxList = $Panel/TabContainer/Vetos/ScrollContainer

##TOPBAR
onready var optionsButton = $Panel/TopBar/OptionsMenu
onready var startButton = $Panel/TopBar/StartButton
onready var channelInfo = $Panel/TopBar/ChannelInfo
onready var sendMsgCheckBox = $Panel/TopBar/SendMsgCheckBox


var show_disconnect_popup #When enabled shows disconnect popup
var player_array: PoolStringArray #The queue
var current_player: String #Self explanatory
var banned_players: Array  #Self explanatory
export(bool) var test_practice = false  #when enabled fills queue with mockup players

#"Cache" for login
var session_user
var session_password
var session_channel

onready var SettingsNode = get_node("/root/ReadWriteSettings")

# Called when the node enters the scene tree for the first time.
func _ready():
#	Set Minimun Window Size
	OS.min_window_size = Vector2(700, 400)
	
	_init_vars()
	
#	Configure RetryDialog window
	retryDialog.get_cancel().text= "Cancelar"
	retryDialog.get_cancel().connect("button_up", self, "_on_ConfirmationDialog_cancel_pressed")
	retryDialog.get_ok().text = "Reintentar"
	retryDialog.get_ok().connect("button_up", self, "_on_ConfirmationDialog_ok_pressed")
#	Configure topbar option button
	optionsButton.get_popup().connect("id_pressed", self, "_on_OptionsMenu_id_pressed")
	
#	Update player list (even if it's empty
	playerScrollContainer.set_player_names(player_array)
	
func _init_vars():
	current_player = String()
	if(SettingsNode.current_settings.has("send_msg_twitch") && not SettingsNode.current_settings["send_msg_twitch"]):
		gift.send_msg = _toggle_options_item(1)
	
	show_disconnect_popup = false
	banned_players = [] #Value -> create a file with banned players and load it
#	Add players for debugging if enabled
	if(test_practice):
		player_array = PoolStringArray(["Jorge", "Jaime", "Jaume", "David", 
		"Maria", "Platano", "Wismichu", "Paria", "Antonio", "Mariano", "Luigiano",
		"Maricarmen", "Tsuneo", "Nohara"])
	else:
		player_array = PoolStringArray()
	
#Get index in queue of player_str
func _get_value_index(player_str : String) -> int:
	for i in range(player_array.size()):
		if(player_str == player_array[i]):
			return i
	return -1

########COMMANDS#########
#Remove All from queue
func clear_queue(cmd: CommandInfo):
	clean_queue_button(cmd.sender_data.user)

#Join Queue
func join_queue(cmd: CommandInfo):
	if(banned_players.find(cmd.sender_data.user) != -1):
		return
		
	var allow = player_array.empty()
	if not allow:
		allow = _get_value_index(cmd.sender_data.user) > -1
	
	if allow:
		player_array.append(cmd.sender_data.user)
		gift.chat_main_channel(cmd.sender_data.user + " se ha unido a la cola! Posicion: " + str(player_array.size()))

#Exit queue
func exit_queue(cmd: CommandInfo):
	var index = _get_value_index(cmd.sender_data.user)
	if(index == -1):
		return
	player_array.remove(index)
	gift.chat_main_channel(cmd.sender_data.user + " te has salido de la cola")

#Remove player from queue
func rmp_queue(cmd: CommandInfo, args: PoolStringArray):
	remove_player_button(cmd.sender_data.user, args[0])

#Remove Current Player and pull next player from queue
func queue_next(cmd: CommandInfo):
	next_player()

#Ban player from entering the queue 
func queue_ban(cmd: CommandInfo, args: PoolStringArray):
	ban_player_button(cmd.sender_data.user, args[0])

#Unban player
func queue_unban(cmd: CommandInfo, args: PoolStringArray):
	unban_player_button(cmd.sender_data.user, args[0])

#Change player position in queue
func queue_commands(cmd: CommandInfo, args:PoolStringArray):
	gift.show_commands()

#Show player what position is they in queue
func queue_position(cmd: CommandInfo):
	var index = _get_value_index(cmd.sender_data.user)

	if index == -1:
		gift.chat_main_channel(cmd.sender_data.user + " no estas en la cola")
	else:
		var text_to_send = cmd.sender_data.user + " estas en la posición " + str(index + 1)
		if index == 0:
			text_to_send += ". Seras el próximo en jugar!"
		gift.chat_main_channel(text_to_send)
	 
#show top 10 players in queue
func queue_top10(cmd: CommandInfo):
	show_top10_queue()
		
#####Signal Answers#####
#Connect to Twitch/Disconnect from Twitch
func _on_ConnectButton_button_up():
	startButton.disabled = true
	if(gift.websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
		show_disconnect_popup = false
		gift.websocket.disconnect_from_host()
	else:
		authDialog.popup_centered()

#On failed login cancel
func _on_ConfirmationDialog_cancel_pressed():
	startButton.disabled = true
	if(gift.websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
		show_disconnect_popup = false
		gift.websocket.disconnect_from_host()

#On Failed login retry
func _on_ConfirmationDialog_ok_pressed():
	gift.init_auth(session_user, session_password)

#Change player position in queue list
func _on_ChangePlayerPosWindow_change_player_position(playername, position):
	change_player_position(BOT_NAME, playername, position)

#ShowCommandsButton action
func _on_ShowCommandsButton_button_up():
	gift.show_commands()

#Topbar Option Selected
func _on_OptionsMenu_id_pressed(id):
	match(id):
		0:
			if(not commandDialog.visible):
				commandDialog.popup_centered()
		1:
			gift.send_msg = _toggle_options_item(id)
			SettingsNode.current_settings["send_msg_twitch"] = gift.send_msg

#Show Window for banning a player (mostly thought for banning players not in queue)
func _on_BanPlayerButton_button_up():
	banPlayerWindow.popup_centered()

#Clear Queue
func _on_CleanQueueButton_button_up():
	clean_queue_button(BOT_NAME)
	
#Ban player given by BanPlayerWindow
func _on_BanPlayerWindow_ban_player(player_str):
	ban_player_button(BOT_NAME, player_str)

func _on_ShowTop10Button_button_up():
	show_top10_queue()

#########Gift Signals###########
func _on_Gift_twitch_connected():
	startButton.disabled = false
	startButton.text = "Desconectar"
	gift.init_auth(session_user, session_password)

func _on_Gift_twitch_disconnected():
	startButton.disabled = false
	startButton.text = "Iniciar"
	errorDialog.dialog_text = "Se ha perdido la conexión con Twitch"
	
	channelInfo.text = "No conectado a ningun canal"
	gift.channels.clear()
	
	if(show_disconnect_popup):
		errorDialog.popup_centered()
	else:
		show_disconnect_popup = true

func _on_Gift_twitch_unavailable():
	startButton.disabled = false
	startButton.text = "Iniciar"
	errorDialog.dialog_text = "No se ha podido conectar con Twitch, comprueba tu conexión o el servicio de Twitch"
	errorDialog.popup_centered()

func _on_Gift_login_attempt(success):
	if success:
		gift.join_channel(session_channel)
		channelInfo.text = "Conectado a #"+session_channel
	else:
		retryDialog.dialog_text = "Error al iniciar sesión"
		retryDialog.popup_centered()

func _on_Gift_cmd_no_permission(cmd_name, sender_data:SenderData, cmd_data, arg_ary):
	gift.chat_main_channel("{sender} no tienes permisos para ejecutar {cmd}".format({sender = sender_data.user, cmd = cmd_name}))

###########Manual command##############
func clean_queue_button(mod_str: String, send_msg: bool = true):
	player_array.resize(0)
	playerScrollContainer.set_player_names(player_array)
	if(send_msg):
		gift.chat_main_channel("Se ha limpiado la cola, %s" % mod_str)
		
func remove_player_button(mod_str: String, player_str: String, send_msg: bool = true):
	var index = _get_value_index(player_str)
	if (index > -1):
		player_array.remove(index)
		if (send_msg):
			var msg = "%s ha sido eliminado de la cola" % player_str
			gift.chat_main_channel(msg)
		playerScrollContainer.set_player_names(player_array)
	else:
		if (send_msg):
			gift.chat_main_channel(player_str + " no existe en la cola")

func ban_player_button(mod_str: String, player_str: String, send_msg: bool = true):
	var index = banned_players.find(player_str)
	if(index == -1):
		banned_players.append(player_str)
		if(send_msg):
			gift.chat_main_channel("{mod} ha vetado a {banned} de la cola".format({mod = mod_str, banned = player_str}))
	
	remove_player_button(mod_str, player_str, false)
	bannedBoxList.update_banned_players(banned_players.duplicate())
	
func unban_player_button(mod_str: String, player_str: String, send_msg: bool = true):
	var index = banned_players.find(player_str)
	if(index == -1):
		if(send_msg):
			gift.chat_main_channel("{player} no está en la lista de vetados de la cola".format({player = player_str}))
		return
	banned_players.remove(index)
	bannedBoxList.update_banned_players(banned_players.duplicate())
	if(send_msg):
		gift.chat_main_channel("{mod} ha desvetado de la cola a {player}".format({mod = mod_str, player = player_str}))

func next_player(send_msg: bool = true):
	if(player_array.size() == 0):
		if(send_msg):
			gift.chat_main_channel("No hay jugadores en la cola!")
		return
	current_player = player_array[0]
	currentPlayerText.text = current_player
	player_array.invert()
	player_array.remove(player_array.size()-1)
	player_array.invert()
	
	playerScrollContainer.set_player_names(player_array)
	
	if(send_msg):
		gift.chat_main_channel("{player} te toca!".format({player = currentPlayerText.text}))

func change_player_position(mod_str:String, player_str: String, new_pos: int, send_msg: bool = true):
	var index = _get_value_index(player_str)
	if(index == -1):
		if(send_msg):
			gift.chat_main_channel("{mod}, el jugador {ply} no esta en la lista".format({"mod":mod_str, "ply": player_str}))
		return
	
	if(new_pos <= 0):
		if(send_msg):
			gift.chat_main_channel("{mod}, la posicion {p} no es válida".format({"mod":mod_str, "p": new_pos}))
		return
	
	player_array.remove(index)
	var position = new_pos - 1
	if(position > player_array.size()):
		position = player_array.size()
	player_array.insert(position, player_str)
	
	if(send_msg):
		gift.chat_main_channel("Ahora {ply} está en la posición {pos}".format({"ply": player_str, "pos": new_pos}))
		
	playerScrollContainer.set_player_names(player_array)

func show_top10_queue(send_msg: bool = true):
#	if(!send_msg):
#		return
	var texto = ""
	if(current_player == ""):
		texto = "Jugando: Nadie"
	else:
		texto = "Jugando: " + current_player
	texto += " | "
	var size = 10 if (player_array.size() >= 10) else player_array.size()
	if(size > 0):
		for i in range(size):
			texto += str(i+1) + " - " + player_array[i] + " | "
	else:
		texto += "No hay cola"
	if(send_msg):
		gift.chat_main_channel(texto)

#On queue player list and banned player list option selected
func _on_option_select(player_str, id_action):
	if id_action == 1:
		ban_player_button(BOT_NAME, player_str)
	elif id_action == 2:
		remove_player_button(BOT_NAME, player_str)
	elif id_action == 3:
		_change_player_display_window(player_str)
	elif id_action == 4:
		unban_player_button(BOT_NAME, player_str) 

#######AUTH DIALOG##########
func _on_AuthDialog_start_session(user, password, channel):
	session_user = user
	session_password = password
	session_channel = channel
	gift.connect_to_twitch()
	startButton.disabled = true

func _on_AuthDialog_popup_hide():
	startButton.disabled = false

func _on_NextPlayerButton_button_up():
	next_player()

#Disconnect websocket when exiting the app
func _notification(what):
	if(what == NOTIFICATION_WM_QUIT_REQUEST):
		if(gift.websocket.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED):
			show_disconnect_popup = false
			gift.websocket.disconnect_from_host()
		SettingsNode.write_settings_file()

#Show menu for changing the queue position of player_str
func _change_player_display_window(player_str:String):
	var index = _get_value_index(player_str)
	if(index == -1):
		return
	
	changePlayerPosWindow.set_data(player_str, index+1)
	changePlayerPosWindow.popup_centered()

########OTHER###############
func _toggle_options_item(id: int) -> bool:
	var index = optionsButton.get_popup().get_item_index(id)
	optionsButton.get_popup().toggle_item_checked(id)
	return optionsButton.get_popup().is_item_checked(id)
