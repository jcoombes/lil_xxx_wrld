extends KinematicBody2D
class_name Demon

enum Behaviours {WANDER, CHASE, ATTACK, STUNNED, DEAD}

signal dead

# Declare member variables here. Examples:
# var a = 2
# var b = "text"]
const CHASE_SPEED: float = 120.0
const WANDER_SPEED: float = 50.0
const KNOCKBACK_SPEED: float = 500.0

var health: float = 10.0

var state: int = Behaviours.WANDER
var target: PhysicsBody2D = null

var wander_direction := Vector2()
var velocity := Vector2()

var player: Player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	z_index = int(position.y)

	var angle: float = velocity.angle()
	
	if 7 * PI / 8 <= angle or angle < - 7 * PI / 8:
		($AnimatedSprite as AnimatedSprite).play("down")
	elif -7 * PI / 8 <= angle and angle < -5 * PI / 8:
		($AnimatedSprite as AnimatedSprite).play("side")
	elif -5 * PI / 8 <= angle and angle < -3 * PI / 8:
		($AnimatedSprite as AnimatedSprite).play("up")
	elif -3 * PI / 8 <= angle and angle < -PI / 8:
		($AnimatedSprite as AnimatedSprite).play("side")
	elif -PI / 8 <= angle and angle < PI / 8:
		($AnimatedSprite as AnimatedSprite).play("down")
	elif PI / 8 <= angle and angle < 3 * PI / 8:
		($AnimatedSprite as AnimatedSprite).play("side")
	elif 3 * PI / 8 <= angle and angle < 5 * PI / 8:
		($AnimatedSprite as AnimatedSprite).play("up")
	elif 5 * PI / 8 <= angle and angle < 7 * PI / 8:
		($AnimatedSprite as AnimatedSprite).play("side")


func _physics_process(delta: float) -> void:
	match state:
		Behaviours.WANDER:
			velocity = WANDER_SPEED * wander_direction
		Behaviours.CHASE:
			if player != null:
				var chase_direction: Vector2 = (player.position - position).normalized()
				velocity = CHASE_SPEED * chase_direction
		_:
			pass
	
	var _collided: KinematicCollision2D = move_and_collide(velocity * delta)


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area is Weapon:
		health -= area.damage
		state = Behaviours.STUNNED
		($StunTimer as Timer).start()
		velocity = (position - area.find_parent("*Player*").position).normalized() * KNOCKBACK_SPEED
			
		if health <= 0.0:
			emit_signal("dead", self)


func _on_WanderTimer_timeout() -> void:
	var p: float = randf()
	
	if p > 0.2:
		var phi: float = randf() * 2 * PI
		wander_direction = Vector2(1, 0).rotated(phi)
	else:
		wander_direction = Vector2()


func _on_StunTimer_timeout():
	if player != null:
		state = Behaviours.CHASE
	else:
		state = Behaviours.WANDER


func _on_SightCone_body_entered(body):
	if "Player" in body.name:
		print("Chasing ", body.name)
		player = (body as Player)
		state = Behaviours.CHASE

func _on_SightCone_body_exited(body):
	if body == player:
		print("Giving up the chase")
		player = null
		state = Behaviours.WANDER
