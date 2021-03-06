extends Control

signal fell_asleep
var gems
var min_gems: int = 0 setget set_min_gems

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var asleep_presses = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setup(min_gems_: int) -> void:
	set_min_gems(min_gems_)


func set_min_gems(min_gems_: int) -> void:
	min_gems = min_gems_
	
	var slider: TextureProgress = ($TextureProgress as TextureProgress)
	
	match min_gems:
		0: 
			slider.cap = 100.0
			slider.value = 100.0
		1:
			slider.cap = 70.0
			slider.value = 70.0
		2:
			slider.cap = 40.0
			slider.value = 40.0
		_:
			slider.cap = 0.0
			slider.value = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var slider: VSlider = $"TextureProgress/VSlider" as VSlider
	
	if Input.is_action_pressed("ui_down"):
		slider.value -= 1
	if Input.is_action_pressed("ui_up"):
		slider.value += 1


func _on_Lyrics_faded_out():
	print("Val is " + str($"TextureProgress".value))
	if $"TextureProgress".value >= 70:
		gems = 1
		emit_signal("fell_asleep", gems)
	elif $"TextureProgress".value >= 40:
		gems = 2
		emit_signal("fell_asleep", gems)
	else:
		gems = 3
		emit_signal("fell_asleep", gems)


func _on_Fall_Asleep_button_up():
	asleep_presses += 1
	
	# skip transition if the player clicks the button twice
	if asleep_presses == 2:
		_on_Lyrics_faded_out()
