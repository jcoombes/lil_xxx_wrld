extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)
		
		dir.list_dir_end()
	
	return files

func fetch_lyrics(drunkness: int):
	files = list_files_in_directory("res://assets/juice_corpus")
	var choice = files[randi() % files.size()]
	
	var file = File.new()
	file.open("res://assets/juice_corpus/wasted.txt", file.READ)
	var content = file.get_as_text()
	print(content)
	file.close()
	return content
	# self.text =
	
var drank: int

func _on_Fall_Asleep_button_up():
	drank = 100 - $"../TextureProgress/VSlider".value
	self.text = fetch_lyrics(drank)
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
