extends KinematicBody2D

enum Behaviours {WANDER, CHASE, ATTACK, DEAD}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const WANDER_SPEED: float = 100.0

var health: float = 10.0

var state: int = Behaviours.WANDER
var target: PhysicsBody2D = null

var wander_direction := Vector2()
var velocity := Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	z_index = int(position.y)
	
	if health <= 0.0:
		free()


func _physics_process(delta: float) -> void:
	match state:
		Behaviours.WANDER:
			velocity = WANDER_SPEED * wander_direction
		_:
			pass
	
	var _collided: KinematicCollision2D = move_and_collide(velocity * delta)

func _on_Hitbox_area_entered(area: Area2D) -> void:
	health -= area.damage


func _on_WanderTimer_timeout() -> void:
	var p: float = randf()
	
	if p > 0.2:
		var phi: float = randf() * 2 * PI
		wander_direction = Vector2(1, 0).rotated(phi)
	else:
		wander_direction = Vector2()