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

# Enable tank?
onready var canDisable = $"Presence/Tank Enabled"
onready var pNum = $"Presence/Player Number"

# Identification
onready var tankColor = $"Identification/Tank Color"

func setProperties(num, color):
	canDisable.visible = num >= 3
	pNum.text = "Player %d" % num
	tankColor.color = color
