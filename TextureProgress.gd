extends TextureProgress


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cap: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VSlider_value_changed(_value: float) -> void:
	value = min(cap, _value)
