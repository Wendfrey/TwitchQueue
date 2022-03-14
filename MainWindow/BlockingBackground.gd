extends ColorRect

export(Array) var popupDialogs 


# Called when the node enters the scene tree for the first time.
func _ready():
	for popupNodePath in popupDialogs:
		assert(popupNodePath is NodePath)
		var node = get_node(popupNodePath)
		assert(node is Popup)
		node.connect("about_to_show", self, "_about_to_show")
		node.connect("popup_hide", self, "_popup_hide")
			 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _about_to_show():
	visible = true

func _popup_hide():
	visible = false
