extends VSlider


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cap: float


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VSlider_value_changed(value_: float) -> void:
	value = min(cap, value_)
