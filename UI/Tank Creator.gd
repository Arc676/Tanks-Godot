extends VBoxContainer

# Enable tank?
onready var canDisable = $"Presence/Tank Enabled"
onready var pNum = $"Presence/Player Number"

# Identification
onready var tankColor = $"Identification/Tank Color"

func setProperties(num, color):
	canDisable.visible = num >= 3
	pNum.text = "Player %d" % num
	tankColor.color = color
