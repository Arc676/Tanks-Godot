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

onready var enableSFX = $"VBoxContainer/Enable SFX"
onready var enableTouchUI = $"VBoxContainer/Enable Touch UI"

onready var saveList = $"VBoxContainer/Save Files"

func _ready():
	enableSFX.pressed = Globals.gameSettings.sfx
	enableTouchUI.pressed = Globals.gameSettings.touchUI

	var dir = Directory.new()
	if dir.open("user://tanks") == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		while filename != "":
			if !dir.current_is_dir():
				var entry = savefile.instance()
				saveList.add_child(entry)
				entry.loadSave(filename.get_basename())
			filename = dir.get_next()

func returnToMain():
	Globals.saveSettings()
	tree.change_scene("res://Scenes/Screens/Main Menu.tscn")

func setSFX(pressed):
	Globals.gameSettings.sfx = pressed

func setTouchUI(pressed):
	Globals.gameSettings.touchUI = pressed
