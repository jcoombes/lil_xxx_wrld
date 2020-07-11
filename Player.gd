extends KinematicBody2D

enum Envelope {ATTACK, DECAY, SUSTAIN, RELEASE}

# time it takes to hit max speed (seconds)
const ATTACK_DURATION: float = 0.2
# time it takes to move from peak speed to sustain speed (seconds)
const DECAY_DURATION: float = 1.0
# time it takes to go from sustain speed to zero (seconds)
const RELEASE_DURATION: float = 0.2

const PEAK_SPEED: float = 200.0
const SUSTAIN_SPEED: float = 180.0

var velocity := Vector2()
var movement_direction := Vector2()
var facing_direction := Vector2()
var _phase: int = Envelope.RELEASE
var combo: int = 0

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
	if Input.is_action_just_pressed("ui_accept"):
		match combo:
			0:
				# swing to the right
				($Sword as Area2D).transform = Transform2D.IDENTITY.rotated(facing_direction.angle())
				($AnimationPlayer as AnimationPlayer).play("attack_down")
				combo = 1
			1:
				# swing to the left
				($Sword as Area2D).transform = Transform2D.IDENTITY.scaled(Vector2(-1, 1)).rotated(facing_direction.angle() + PI)
				($AnimationPlayer as AnimationPlayer).play("attack_down")
				combo = 0
		($ComboResetTimer as Timer).start()

func _physics_process(delta: float) -> void:
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
			min_speed = 0.0
			max_speed = PEAK_SPEED
		Envelope.DECAY:
			acceleration = (SUSTAIN_SPEED - PEAK_SPEED) / DECAY_DURATION
			min_speed = SUSTAIN_SPEED
			max_speed = PEAK_SPEED
		Envelope.SUSTAIN:
			acceleration = (PEAK_SPEED - 0.0) / ATTACK_DURATION
		Envelope.RELEASE:
			acceleration = (0.0 - SUSTAIN_SPEED) / RELEASE_DURATION
	
	velocity = clamp(speed + delta * acceleration, min_speed, max_speed) * movement_direction
	
	var _collision = move_and_collide(velocity * delta)
	
	z_index = int(position.y)

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass


func _on_Sword_area_entered(area: Area2D) -> void:
	area.take_damage()


func _on_ComboResetTimer_timeout():
	combo = 0
