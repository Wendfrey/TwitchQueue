extends ScrollContainer

const childType : PackedScene = preload("res://MainWindow/PlayerLabel/PlayerLabel.tscn")

export(NodePath) var listenerNodepath

onready var listenerNode = get_node(listenerNodepath)
onready var vBox = $VBoxContainer

var empty: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	when_no_players()

func set_player_names(player_names: PoolStringArray):
	if(empty):
		vBox.get_child(0).free() #Remove PlaceHolder label
		
	var difference = player_names.size() - vBox.get_child_count()
	if(difference > 0):
		for i in range(difference):
			vBox.add_child(generate_child_view())
	elif (difference < 0):
		difference = abs(difference)
		for i in range(difference):
			vBox.remove_child(vBox.get_children()[0])
			
	if(vBox.get_child_count() == 0):
		when_no_players()
		return;

	empty = false
	var children = vBox.get_children()
	for i in range(player_names.size()):
		children[i].set_data(str(i+1) + " - ", player_names[i])
		
#Add placeholder Label
func when_no_players():
	if(vBox.get_child_count() > 0):
		return
	empty = true
	vBox.add_child(Label.new())
	vBox.get_child(0).text = "\tCola vacia"

func generate_child_view() -> PlayerLabel:
	var button:PlayerLabel = childType.instance()
	button.connect("option_selected", listenerNode, "_on_option_select")
	return button
