extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var song_titles = ["Felt sad, might delete later.",
"Demons and Bitches", 
"Red solo cup Han solo", 
"Spit Take (Slurp the drank)",
"HeXperiences",
"Shawty is a dwarf",
"Brotherz (feat. Evil Rhombus)",
"Fighting actual sleep demons",
"Don't U believe me?",
"Literally just voicemails"]

var day: int
var gems: int
var gems_total: int

func setup(days_elapsed, gems_from_gm, total_gems_from_gm):
	self.day = days_elapsed
	self.gems = gems_from_gm
	self.gems_total = total_gems_from_gm
# Called when the node enters the scene tree for the first time
func _ready():
	$ColorRect/ColorRect/ColorRect2/SongTitle.text = song_titles[day]
	$ColorRect/Label.text = "You got " +str(gems) + "gems. \n You have" + str(gems_total) + "total"
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
