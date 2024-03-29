# Copyright (C) 2021 Arc676/Alessandro Vinciguerra <alesvinciguerra@gmail.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation (version 3)

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

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

var defaultColor

# Enable tank?
onready var enableTank = $"Presence/Tank Enabled"
onready var pNum = $"Presence/Player Number"

# Disk
var loadedTank = null
onready var loadDialog = $"Load Dialog"
onready var loadFailed = $"Load Failed"

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
	$Team.visible = Globals.gameSettings.teams

func setProperties(num, color):
	enableTank.visible = num >= 3
	pNum.text = "Player %d" % num
	defaultColor = color
	tankColor.color = color

func getTank():
	if !enableTank.pressed:
		return null
	if is_instance_valid(loadedTank):
		return loadedTank
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

func setEditable(editable, isLoaded = false):
	tankName.editable = editable and !isLoaded
	tankTeam.editable = editable and !isLoaded
	tankColor.disabled = !editable or isLoaded
	tankIsCC.disabled = !editable or isLoaded
	aiDiff.disabled = !editable or !tankIsCC.pressed
	aiStyle.disabled = !editable or !tankIsCC.pressed
	$Disk/Load.disabled = !editable or isLoaded
	$Disk/Unload.disabled = !isLoaded

func loadTank():
	if tankName.text.length() > 0:
		loadTankWithName(tankName.text)
	else:
		loadDialog.popup_centered_ratio(0.4)

func loadTankWithName(name):
	loadedTank = tankObj.instance()
	if loadedTank.loadFromDisk(name):
		tankName.text = name
		tankTeam.text = loadedTank.team
		tankColor.color = loadedTank.color
		tankIsCC.pressed = loadedTank.isCC
		if loadedTank.isCC:
			aiDiff.select(loadedTank.aiLvl)
			aiStyle.select(loadedTank.aiStyle)
		setEditable(false, true)
	else:
		loadFailed.popup_centered_ratio(0.4)
		loadedTank.queue_free()

func unloadTank():
	loadedTank.queue_free()
	loadedTank = null
	tankName.text = ""
	tankTeam.text = ""
	tankColor.color = defaultColor
	setEditable(true)

func toggleTank(enable):
	setEditable(enable, enable and is_instance_valid(loadedTank))

func toggleCC(pressed):
	aiDiff.disabled = !pressed
	aiStyle.disabled = !pressed
