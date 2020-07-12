extends KinematicBody2D
class_name Player

enum Behaviours {ALIVE, RECOILING, STUNNED, DEAD}
enum Envelope {ATTACK, DECAY, SUSTAIN, RELEASE}

signal health_changed
signal dead

# time it takes to hit max speed (seconds)
const ATTACK_DURATION: float = 0.2
# time it takes to move from peak speed to sustain speed (seconds)
const DECAY_DURATION: float = 1.0
# time it takes to go from sustain speed to zero (seconds)
const RELEASE_DURATION: float = 0.2

const PEAK_SPEED: float = 200.0
const SUSTAIN_SPEED: float = 180.0
const KNOCKBACK_SPEED: float = 300.0

var velocity := Vector2()
var movement_direction := Vector2()
var facing_direction := Vector2()
var _phase: int = Envelope.RELEASE
var combo: int = 0
var cooling_down: bool = false

var health: float = 10.0 setget set_health
var state: int = Behaviours.ALIVE


func set_health(value: float) -> void:
	health = value
	emit_signal("health_changed", self, value)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if velocity.length() > 0.0:
		if velocity.y > 0.0:
			($AnimatedSprite as AnimatedSprite).play("move_down")
		elif velocity.y < 0.0:
			($AnimatedSprite as AnimatedSprite).play("move_up")
		elif velocity.x > 0.0:
			($AnimatedSprite as AnimatedSprite).play("move_right")
		elif velocity.x < 0.0:
			($AnimatedSprite as AnimatedSprite).play("move_left")
	else:
		($AnimatedSprite as AnimatedSprite).play("idle")
	
	# borrowing "accept" for "attack"
	if Input.is_action_just_pressed("sword_attack") and state != Behaviours.STUNNED:
		match combo:
			0:
				# swing to the right
				($Sword as Area2D).transform = Transform2D.IDENTITY.rotated(facing_direction.angle())
				play_attack_animation(facing_direction)
				combo = 1
			1:
				# swing to the left
				($Sword as Area2D).transform = Transform2D.IDENTITY.scaled(Vector2(-1, 1)).rotated(facing_direction.angle() + PI)
				play_attack_animation(facing_direction)
				combo = 0
		($ComboResetTimer as Timer).start()
	

func play_attack_animation(direction: Vector2) -> void:
	if direction.y > 0.0:
		($AnimationPlayer as AnimationPlayer).play("attack_down")
	elif velocity.y < 0.0:
		($AnimationPlayer as AnimationPlayer).play("attack_up")
	elif velocity.x > 0.0:
		($AnimationPlayer as AnimationPlayer).play("attack_right")
	elif velocity.x < 0.0:
		($AnimationPlayer as AnimationPlayer).play("attack_left")
	else:
		($AnimationPlayer as AnimationPlayer).play("attack_down")


func _physics_process(delta: float) -> void:
	match state:
		Behaviours.ALIVE:
			do_movement(delta)
			do_facing(delta)
		Behaviours.RECOILING:
			var _collision = move_and_collide(velocity * delta)
			do_facing(delta)
		Behaviours.STUNNED:
			var _collision = move_and_collide(velocity * delta)
		Behaviours.DEAD:
			pass


func do_facing(_delta: float) -> void:
	var new_direction := Vector2()
	
	if Input.is_action_pressed("face_right"):
		new_direction.x += 1
	if Input.is_action_pressed("face_left"):
		new_direction.x -= 1
	if Input.is_action_pressed("face_up"):
		new_direction.y -= 1
	if Input.is_action_pressed("face_down"):
		new_direction.y += 1
	
	if new_direction.length() > 0:
		new_direction = new_direction.normalized()
		facing_direction = new_direction


func do_movement(delta: float) -> void:
	var new_direction := Vector2()
	
	if Input.is_action_pressed("ui_right"):
		new_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		new_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		new_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		new_direction.y -= 1
	
	new_direction = new_direction.normalized()
	
	var speed: float = velocity.length()
	
	if new_direction.length() > 0.0:
		movement_direction = new_direction
		facing_direction = new_direction
		match _phase:
			Envelope.RELEASE:
				if speed == 0.0:
					_phase = Envelope.ATTACK
				elif speed > SUSTAIN_SPEED:
					_phase = Envelope.DECAY
				elif speed < SUSTAIN_SPEED:
					_phase = Envelope.SUSTAIN
			Envelope.ATTACK:
				if speed >= PEAK_SPEED:
					_phase = Envelope.DECAY
			Envelope.DECAY:
				if speed <= SUSTAIN_SPEED:
					_phase = Envelope.SUSTAIN
			Envelope.SUSTAIN:
				pass
	else:
		_phase = Envelope.RELEASE
	
	var acceleration: float
	var min_speed: float = 0.0
	var max_speed: float = SUSTAIN_SPEED
	
	match _phase:
		Envelope.ATTACK:
			acceleration = (PEAK_SPEED - 0.0) / ATTACK_DURATION
			max_speed = PEAK_SPEED
		Envelope.DECAY:
			acceleration = (SUSTAIN_SPEED - PEAK_SPEED) / DECAY_DURATION
			min_speed = SUSTAIN_SPEED
			max_speed = PEAK_SPEED
		Envelope.SUSTAIN:
			acceleration = (PEAK_SPEED - 0.0) / ATTACK_DURATION
		Envelope.RELEASE:
			acceleration = (0.0 - SUSTAIN_SPEED) / RELEASE_DURATION
	
	# velocity might not be in the direction of motion because of knockback
	velocity = clamp(speed + delta * acceleration, min_speed, max_speed) * movement_direction

	var _collision = move_and_collide(velocity * delta)

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass


func _on_Sword_area_entered(area: Area2D) -> void:
	var recoil_direction: Vector2 = (position - area.find_parent("Demon").position).normalize()
	velocity = $Sword.recoil * recoil_direction
	state = Behaviours.RECOILING
	_phase = Envelope.RELEASE
	($RecoilTimer as Timer).start()


func _on_ComboResetTimer_timeout():
	combo = 0


func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area is Weapon:
		set_health(health - area.damage)
		
		state = Behaviours.STUNNED
		($StunTimer as Timer).start()
		velocity = (position  - area.position).normalized() * KNOCKBACK_SPEED
		
		if health <= 0.0:
			emit_signal("dead", self)
			state = Behaviours.DEAD
			($AnimatedSprite as AnimatedSprite).visible = false


func _on_RecoilTimer_timeout():
	state = Behaviours.ALIVE


func _on_KnockbackTimer_timeout():
	state = Behaviours.ALIVE
