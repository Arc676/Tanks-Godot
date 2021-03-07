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

extends Node

const GRAVITY = 981

var gameSettings = {
	"teams" : false,
	"sfx" : true,
	"touchUI" : true
}

var SCR_WIDTH
var SCR_HEIGHT

var _loaded = false
var players = []
var selectedTerrain = Terrain.TerrainType.DESERT

func _enter_tree():
	if Globals._loaded:
		printerr("Error: Globals is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + get_path())
	else:
		Globals._loaded = true
		if !OS.has_touchscreen_ui_hint():
			get_tree().set_screen_stretch(
				SceneTree.STRETCH_MODE_DISABLED,
				SceneTree.STRETCH_ASPECT_IGNORE,
				get_viewport().size
			)
		SCR_WIDTH = get_viewport().size.x
		SCR_HEIGHT = get_viewport().size.y

		# Load settings
		var file = File.new()
		if file.file_exists("user://settings/settings.json"):
			file.open("user://settings/settings.json", File.READ)
			gameSettings = parse_json(file.get_line())
			file.close()
		else:
			saveSettings()

func saveSettings():
	var dir = Directory.new()
	if !dir.dir_exists("user://settings/"):
		if dir.make_dir_recursive("user://settings/") != OK:
			return false
	var file = File.new()
	file.open("user://settings/settings.json", File.WRITE)
	file.store_line(to_json(gameSettings))
	file.close()
	return true
