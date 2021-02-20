extends Control

onready var tree = get_tree()

onready var p1 = $"Players/Player 1"
onready var p2 = $"Players/Player 2"
onready var p3 = $"Players/Player 3"
onready var p4 = $"Players/Player 4"

func _ready():
	p1.setProperties(1, Color(0, 0, 1))
	p2.setProperties(2, Color(1, 0, 0))
	p3.setProperties(3, Color(0, 1, 0))
	p4.setProperties(4, Color(1, 1, 0))

func startGame():
	tree.change_scene("res://Scenes/Game.tscn")

func quitGame():
	tree.quit()
