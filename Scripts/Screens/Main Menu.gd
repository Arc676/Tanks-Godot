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

extends Control

onready var tree = get_tree()

# Players
onready var p1 = $"UI/P13/Player 1"
onready var p2 = $"UI/P24/Player 2"
onready var p3 = $"UI/P13/Player 3"
onready var p4 = $"UI/P24/Player 4"

# Terrain selection
onready var desert = $UI/Terrain/Desert
onready var plains = $UI/Terrain/Plains
onready var hills = $UI/Terrain/Hills
onready var random = $UI/Terrain/Random

func _ready():
	p1.setProperties(1, Color(0, 0, 1))
	p2.setProperties(2, Color(1, 0, 0))
	p3.setProperties(3, Color(0, 1, 0))
	p4.setProperties(4, Color(1, 1, 0))

func startGame():
	Globals.players = [
		p1.getTank(), p2.getTank()
	]
	var tank3 = p3.getTank()
	if tank3:
		Globals.players.append(tank3)
	var tank4 = p4.getTank()
	if tank4:
		Globals.players.append(tank4)

	if desert.pressed:
		Globals.selectedTerrain = Terrain.TerrainType.DESERT
	elif plains.pressed:
		Globals.selectedTerrain = Terrain.TerrainType.PLAINS
	elif hills.pressed:
		Globals.selectedTerrain = Terrain.TerrainType.HILLS
	else:
		Globals.selectedTerrain = Terrain.TerrainType.RANDOM
	tree.change_scene("res://Scenes/Screens/Game.tscn")

func quitGame():
	tree.quit()
