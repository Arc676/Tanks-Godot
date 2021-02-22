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

# HUD - Player data
onready var pColor = $"ColorRect/HUD/Player Stats/Identification/Player Color"
onready var pName = $"ColorRect/HUD/Player Stats/Identification/Player Name"
onready var pHP = $"ColorRect/HUD/Player Stats/HBoxContainer/Bars/Health Bar"
onready var pFirepower = $"ColorRect/HUD/Player Stats/HBoxContainer/Bars/Firepower Bar"
onready var pFuel = $"ColorRect/HUD/Player Stats/HBoxContainer/Bars/Fuel Bar"

# HUD - Terrain data
onready var windSpeed = $"ColorRect/HUD/Wind/Wind Bar"

# HUD - Scoreboard
onready var scores = [
	$"ColorRect/HUD/Scoreboard/Score 1",
	$"ColorRect/HUD/Scoreboard/Score 2",
	$"ColorRect/HUD/Scoreboard/Score 3",
	$"ColorRect/HUD/Scoreboard/Score 4"
]

# Game
var activePlayer = 0
var players = []
onready var terrain = $"Game Scene/Terrain"

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	players = []

	terrain.generateNewTerrain(Globals.selectedTerrain,
		Globals.SCR_HEIGHT,
		Globals.SCR_WIDTH)
	var z = 1
	for tank in Globals.players:
		var idx = rng.randi_range(4, terrain.chunkCount - 4)
		tank.position = terrain.ground.polygon[idx] + Vector2.UP * 3
		tank.z_index = z
		z += 1
		add_child_below_node($"Game Scene", tank)
		players.append(tank)

	# Remove unused scoreboard entries
	for i in range(4):
		scores[i].visible = len(players) >= i + 1

	setActiveTank(0)

func toggleSFX(pressed):
	AudioServer.set_bus_mute(1, !pressed)

func drawGame():
	pass # Replace with function body.

func _process(_delta):
	pHP.value = players[activePlayer].hp
	pFirepower.value = players[activePlayer].firepower
	pFuel.value = players[activePlayer].fuel

	for i in range(len(players)):
		var tank = players[i]
		scores[i].text = "%s: %d" % [tank.tankName, tank.score]

func setActiveTank(idx):
	players[idx].isActiveTank = true
	pColor.color = players[idx].color
	pName.text = players[idx].tankName
