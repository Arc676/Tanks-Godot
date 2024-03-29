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

extends Node

const UPGRADE_PROPERTIES = {
	"Engine Efficiency" : {
		"effect" : 1.1,
		"price" : 100
	},
	"Armor" : {
		"effect" : 1.1,
		"price" : 200
	},
	"Extra Fuel" : {
		"effect" : 20,
		"price" : 50
	},
	"Hill Climbing" : {
		"effect" : 1.2,
		"price" : 150
	}
}

const ITEM_PROPERTIES = {
	"Repair Kit" : {
		"price" : 50,
		"hp" : 20
	},
	"Teleport" : {
		"price" : 3000
	},
	"Weak Shield" : {
		"price" : 100,
		"color" : Color.yellow,
		"hp" : 50
	},
	"Medium Shield" : {
		"price" : 500,
		"color" : Color.green,
		"hp" : 200
	},
	"Strong Shield" : {
		"price" : 1000,
		"color" : Color.blue,
		"hp" : 1000
	},
	"Ultimate Shield" : {
		"price" : 3500,
		"color" : Color.purple,
		"hp" : 10000
	}
}

var _loaded = false

func _enter_tree():
	if Items._loaded:
		printerr("Error: Weapons is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + get_path())
	else:
		Items._loaded = true
