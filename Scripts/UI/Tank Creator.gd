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

# Enable tank?
onready var enableTank = $"Presence/Tank Enabled"
onready var pNum = $"Presence/Player Number"

# Identification
onready var tankName = $"Identification/Tank Name"
onready var tankColor = $"Identification/Tank Color"
onready var tankTeam = $"Team/Tank Team"

func setProperties(num, color):
	enableTank.visible = num >= 3
	pNum.text = "Player %d" % num
	tankColor.color = color

func getTank():
	if !enableTank.pressed:
		return null
	var tank = tankObj.instance()
	tank.name = tankName.text
	tank.team = tankTeam.text
	tank.setColor(tankColor.color)
	return tank
