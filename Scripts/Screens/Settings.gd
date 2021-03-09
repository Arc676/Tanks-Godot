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

onready var savefile = preload("res://Scenes/UI/Save File.tscn")

onready var tree = get_tree()


func _ready():
	$"VBoxContainer/Enable SFX".pressed = Globals.gameSettings.sfx
	$"VBoxContainer/Enable Touch UI".pressed = Globals.gameSettings.touchUI
	$"VBoxContainer/Enable Teams".pressed = Globals.gameSettings.teams

	for file in Globals.saveFiles:
		var entry = savefile.instance()
		$"VBoxContainer/Save Files".add_child(entry)
		entry.loadSave(file)

func returnToMain():
	Globals.saveSettings()
	tree.change_scene("res://Scenes/Screens/Main Menu.tscn")

func setSFX(pressed):
	Globals.gameSettings.sfx = pressed

func setTouchUI(pressed):
	Globals.gameSettings.touchUI = pressed

func setTeams(pressed):
	Globals.gameSettings.teams = pressed
