extends Control

signal game_start

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_New_Game_button_up():
	emit_signal("game_start")
	print("signals emitted all up in this bitch")


func _on_New_Game_pressed():
	emit_signal("game_start")  #pass # Replace with function body.
	print("you really pressed that button")
