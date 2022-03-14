extends ScrollContainer

const CHILD_BASE : PackedScene = preload("res://MainWindow/BanedPlayerLabel/BannedPlayerLabel.tscn")

export(NodePath) var listenerNodepath

onready var listener = get_node(listenerNodepath)
onready var vBox = $Container
var empty = false

var bp_list: Array
var bp_list_filtered: Array
var text_filter: String = "*"

func _ready():
	when_no_players()


func update_banned_players(banned_players_list: Array):
	bp_list = banned_players_list
	_internal_reload()


func generate_child_view():
	var button: BannedPlayerLabel = CHILD_BASE.instance()
	button.connect("option_selected", listener, "_on_option_select")
	return button


func when_no_players():
	if(vBox.get_child_count() != 0):
		return
		
	empty = true
	var label = Label.new()
	label.text = "No hay jugadores vetados" if text_filter == "*" else "Ningun jugador vetado cumple con el criterio"
	vBox.add_child(label)


func _internal_reload():
	bp_list_filtered.clear()
	for i in bp_list:
		if i.matchn(text_filter):
			bp_list_filtered.append(i)
	
	if(empty):
		vBox.get_child(0).free() #Remove PlaceHolder label
		
	var difference = bp_list_filtered.size() - vBox.get_child_count()
	if(difference > 0):
		for i in range(difference):
			vBox.add_child(generate_child_view())
	elif (difference < 0):
		difference = abs(difference)
		for i in range(difference):
			vBox.remove_child(vBox.get_children()[0])
			
	if(bp_list_filtered.size() == 0):
		when_no_players()
		return;
		
	empty = false
	for i in range(bp_list_filtered.size()):
		vBox.get_child(i)._set_text(bp_list_filtered[i])


func _on_BuscadorVetados_text_entered(new_text):
	text_filter = new_text.strip_edges()
	if(text_filter == ""):
		text_filter = "*"
	else:
		text_filter.replace(".", "\\.")
		text_filter = "*" + text_filter + "*"
	_internal_reload()
	
