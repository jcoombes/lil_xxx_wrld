extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var health: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	z_index = int(position.y)
	
	if health <= 0.0:
		free()


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("AttackBoxes"):
		health -= area.damage
