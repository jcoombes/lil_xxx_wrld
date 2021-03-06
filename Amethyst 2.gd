extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
var previously_made_visible = false

func _on_TextureProgress_value_changed(value):
	if value < 40:
		self.visible = true
		previously_made_visible = true
	elif previously_made_visible and value >= 40:
		self.visible = false
		previously_made_visible = false
