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
onready var p1Score = $"ColorRect/HUD/Scoreboard/Score 1"
onready var p2Score = $"ColorRect/HUD/Scoreboard/Score 2"
onready var p3Score = $"ColorRect/HUD/Scoreboard/Score 3"
onready var p4Score = $"ColorRect/HUD/Scoreboard/Score 4"

# Game
var activePlayer = 0
var players = []
onready var terrain = $"Game Scene/Terrain"

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	players = []

	terrain.generateNewTerrain(Globals.selectedTerrain,
		get_viewport().size.y,
		get_viewport().size.x)
	for tank in Globals.players:
		var idx = rng.randi_range(4, terrain.chunkCount - 4)
		tank.position = terrain.ground.polygon[idx] + Vector2.UP * 10
		add_child_below_node($"Game Scene", tank)
		players.append(tank)

func toggleSFX(pressed):
	AudioServer.set_bus_mute(1, !pressed)

func drawGame():
	pass # Replace with function body.

func _process(_delta):
	pHP.value = players[activePlayer].hp
	pFirepower.value = players[activePlayer].firepower
	pFuel.value = players[activePlayer].fuel
