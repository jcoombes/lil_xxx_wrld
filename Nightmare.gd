extends Node2D

signal victory
signal defeat

const PLAYER_SPAWN_POINTS: Array = [Vector2(512, 128)]
const DEMON_SPAWN_POINTS: Array = [Vector2(512, 448), Vector2(256, 296), Vector2(768, 296)]
const Demon = preload("res://Demon.tscn")
const Player = preload("res://Player.tscn")

var demons_remaining: int = 0
var lives: int = 1
# var a = 2
# var b = "text"


func setup(n_demons: int):
	spawn_player()
	
	for _i in range(n_demons):
		spawn_demon()


func spawn_player():
	var player: Player = Player.instance()
	self.add_child(player)
	var spawn_point: Vector2 = (PLAYER_SPAWN_POINTS[randi() % PLAYER_SPAWN_POINTS.size()] as Vector2)
	player.position = spawn_point
	player.velocity = Vector2()
	
	($"UI/HealthBar" as TextureProgress).max_value = player.health
	($"UI/HealthBar" as TextureProgress).min_value = 0
	
	var error: int = player.connect("dead", self, "_on_Player_dead")
	if error != OK:
		print("Error: ", error)
	
	error = player.connect("health_changed", self, "_on_Player_health_changed")
	if error != OK:
		print("Error: ", error)


func _on_Player_dead(player: Player) -> void:
	self.remove_child(player)
	# player is locked because it's sending a signal, so we have to use call_deferred here
	player.call_deferred("free")
	lives -= 1
	
	if lives > 0:
		spawn_player()
	else:
		emit_signal("defeat")
	

func _on_Player_health_changed(_player: Player, new_value: float) -> void:
	($"UI/HealthBar" as TextureProgress).value = new_value


func spawn_demon():
	var demon: Demon = Demon.instance()
	self.add_child(demon)
	var spawn_point: Vector2 = (DEMON_SPAWN_POINTS[randi() % DEMON_SPAWN_POINTS.size()] as Vector2)
	demon.position = spawn_point
	demon.velocity = Vector2()
	
	var error: int = demon.connect("dead", self, "_on_Demon_dead")
	if error != OK:
		print("Error: ", error)
		
	demons_remaining += 1


func _on_Demon_dead(demon: Demon) -> void:
	self.remove_child(demon)
	# demon is locked because it's sending a signal, so we have to use call_deferred here
	demon.call_deferred("free")
	demons_remaining -= 1
	if demons_remaining == 0:
		emit_signal("victory")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


