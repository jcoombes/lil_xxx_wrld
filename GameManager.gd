extends Node
class_name GameManager


enum Scenes {MAIN_MENU, DAYTIME, NIGHTMARE}

const MainMenu = preload("res://Main_menu.tscn")
const Daytime = preload("res://Daytime.tscn")
const Nightmare = preload("res://Nightmare.tscn")


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var score: int = 0
var current_scene: int = Scenes.MAIN_MENU
var current_scene_node: Node = null


# Called when the node enters the scene tree for the first time.
func _ready():
	transition_to(Scenes.MAIN_MENU)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func transition_to(scene_id: int) -> void:
	if current_scene_node != null:
		self.remove_child(current_scene_node)
		# current_scene_node is usually locked because it's emitting a signal
		# this calls free on it next frame when it's unlocked
		current_scene_node.call_deferred("free")
	
	current_scene = scene_id
	
	match scene_id:
		Scenes.MAIN_MENU:
			current_scene_node = MainMenu.instance()
			self.add_child(current_scene_node)
			var error: int = current_scene_node.connect("game_start", self, "_on_Main_Menu_game_start")
			if error != OK:
				print("Error: ", error)
			
		Scenes.DAYTIME:
			current_scene_node = Daytime.instance()
			self.add_child(current_scene_node)
			var error: int = current_scene_node.connect("fell_asleep", self, "_on_Daytime_fell_asleep")
			if error != OK:
				print("Error: ", error)
		
		Scenes.NIGHTMARE:
			current_scene_node = Nightmare.instance()
			current_scene_node.setup(1)
			self.add_child(current_scene_node)
			
			var error: int = current_scene_node.connect("defeat", self, "_on_Nightmare_defeat")
			if error != OK:
				print("Error: ", error)
			
			error = current_scene_node.connect("victory", self, "_on_Nightmare_victory")
			if error != OK:
				print("Error: ", error)


func _on_Main_Menu_game_start():
	transition_to(Scenes.DAYTIME)


func _on_Daytime_fell_asleep():
	transition_to(Scenes.NIGHTMARE)


func _on_Nightmare_defeat():
	transition_to(Scenes.MAIN_MENU)


func _on_Nightmare_victory():
	transition_to(Scenes.DAYTIME)
