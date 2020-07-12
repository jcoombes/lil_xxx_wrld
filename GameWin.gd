extends Control

signal scene_end

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setup(n_gems):
	$Label.text += "\n\nWhen your stomach was pumped, they found " + str(n_gems * 20) + " ml of Faust brand energy drink"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		emit_signal("scene_end")
