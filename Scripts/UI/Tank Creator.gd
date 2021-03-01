# Copyright (C) 2021 Arc676/Alessandro Vinciguerra <alesvinciguerra@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation (version 3)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

extends VBoxContainer

onready var tankObj = preload("res://Scenes/Entities/Tank.tscn")

const names = [
	"Alpha",
	"Bravo",
	"Charlie",
	"Delta",
	"Echo",
	"Foxtrot",
	"Golf",
	"Hotel",
	"India",
	"Juliet",
	"Kilo",
	"Lima",
	"Mike",
	"November",
	"Oscar",
	"Papa",
	"Quebec",
	"Romeo",
	"Sierra",
	"Tango",
	"Uniform",
	"Victor",
	"Whiskey",
	"X-ray",
	"Yankee",
	"Zulu"
]

# Enable tank?
onready var enableTank = $"Presence/Tank Enabled"
onready var pNum = $"Presence/Player Number"

# Identification
onready var tankName = $"Identification/Tank Name"
onready var tankColor = $"Identification/Tank Color"
onready var tankTeam = $"Team/Tank Team"

# Computer controlled tank
onready var tankIsCC = $"AI Mode/CC"
onready var aiDiff = $"AI Mode/Difficulty"
onready var aiStyle = $"AI Mode/Style"

func _enter_tree():
	if !OS.has_touchscreen_ui_hint():
		size_flags_vertical = SIZE_FILL
		for node in get_children():
			node.size_flags_vertical = SIZE_FILL

func setProperties(num, color):
	enableTank.visible = num >= 3
	pNum.text = "Player %d" % num
	tankColor.color = color

func getTank():
	if !enableTank.pressed:
		return null
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var tank = tankObj.instance()
	if tankName.text == "":
		tank.tankName = names[rng.randi_range(0, 25)]
	else:
		tank.tankName = tankName.text
	tank.team = tankTeam.text
	tank.setColor(tankColor.color)
	if tankIsCC.pressed:
		tank.isCC = true
		tank.aiLvl = aiDiff.selected
		if aiStyle.selected == 2:
			tank.aiStyle = rng.randi_range(0, 1)
		else:
			tank.aiStyle = aiStyle.selected
	return tank
