extends Control

signal fell_asleep

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var asleep_presses = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Lyrics_faded_out():
	emit_signal("fell_asleep")


func _on_Fall_Asleep_button_up():
	asleep_presses += 1
	
	# skip transition if the player clicks the button twice
	if asleep_presses == 2:
		emit_signal("fell_asleep")
