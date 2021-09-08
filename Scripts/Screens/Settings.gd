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

extends Control

onready var savefile = preload("res://Scenes/UI/Save File.tscn")

onready var tree = get_tree()

func _ready():
	$"Rows/Options/UI/Enable SFX".pressed = Globals.gameSettings.sfx
	$"Rows/Options/UI/Enable Touch UI".pressed = Globals.gameSettings.touchUI
	$"Rows/Options/UI/Enable Teams".pressed = Globals.gameSettings.teams
	$"Rows/Options/UI/Enable Help Overlay".pressed = Globals.gameSettings.showHelpOverlay

	$Rows/Options/Gameplay/Shuffle.pressed = Globals.gameSettings.shuffleOrder
	$"Rows/Options/Gameplay/Difficulty/Difficulty Slider".value = 1 - inverse_lerp(
		1, 1.8,
		Globals.gameSettings.scaleDmgDist
	)
	$"Rows/Options/Gameplay/Enable CC Scaling".pressed = Globals.gameSettings.scaleForCCs
	$Rows/Options/Gameplay/Wind/Wind.selected = Globals.gameSettings.wind

	for file in Globals.saveFiles:
		var entry = savefile.instance()
		$"Rows/Save Files".add_child(entry)
		entry.loadSave(file)

func returnToMain():
	Globals.saveSettings()
	Globals.findSaveFiles()
	tree.change_scene("res://Scenes/Screens/Main Menu.tscn")

func setSFX(pressed):
	Globals.gameSettings.sfx = pressed

func setTouchUI(pressed):
	Globals.gameSettings.touchUI = pressed

func setTeams(pressed):
	Globals.gameSettings.teams = pressed

func changeWindSetting(setting):
	Globals.gameSettings.wind = setting

func setDifficulty(value):
	Globals.gameSettings.scaleDmgDist = lerp(1, 1.8, 1 - value)

func toggleCCScaling(pressed):
	Globals.gameSettings.scaleForCCs = pressed

func toggleShufflePlayers(pressed):
	Globals.gameSettings.shuffleOrder = pressed

func toggleOverlay(pressed):
	Globals.gameSettings.showHelpOverlay = pressed
