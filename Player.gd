extends KinematicBody2D

enum Envelope {ATTACK, DECAY, SUSTAIN, RELEASE}

# time it takes to hit max speed (seconds)
export var ATTACK_DURATION: float = 0.5
# time it takes to move from peak speed to sustain speed (seconds)
export var DECAY_DURATION: float = 0.1
# time it takes to go from sustain speed to zero (seconds)
export var RELEASE_DURATION: float = 0.1

export var PEAK_SPEED: float = 100.0
export var SUSTAIN_SPEED: float = 50.0

var velocity := Vector2()
var _phase: int = Envelope.RELEASE
var _input_duration: float = 0.0
var _decay_duration: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta: float) -> void:
	var direction := Vector2()
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	direction = direction.normalized()
	
	var any_input: bool = direction.length() > 0.0
	var speed: float = velocity.length()
	
	if any_input:
		_input_duration += delta
		
		match _phase:
			Envelope.RELEASE:
				_phase = Envelope.ATTACK
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
	
	match _phase:
		Envelope.ATTACK:
			acceleration = (PEAK_SPEED - 0.0) / ATTACK_DURATION
		Envelope.DECAY:
			acceleration = (SUSTAIN_SPEED - PEAK_SPEED) / DECAY_DURATION
		Envelope.SUSTAIN:
			acceleration = 0.0
		Envelope.RELEASE:
			acceleration = (0.0 - SUSTAIN_SPEED) / RELEASE_DURATION
	
	velocity = max(0.0, speed + delta * acceleration) * direction
	print(velocity)
	print(_phase)
	var _collision = move_and_collide(velocity * delta)

func _integrate_forces(_state: Physics2DDirectBodyState) -> void:
	pass
