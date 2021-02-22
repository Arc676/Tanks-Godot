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

onready var projObj = preload("res://Scenes/Entities/Projectile.tscn")

const STANDARD_WEAPONS = [
	"Tank Shell",
	"Missile",
	"Armor Piercing Shell",
	"Atom Bomb",
	"Hydrogen Bomb"
]

const LARGE_EXPLOSIONS = [
	"Atom Bomb",
	"Hydrogen Bomb",
	"Hailfire III",
	"Hailfire IV"
]

const WEAPON_PROPERTIES = {
	"Tank Shell" : {
		"radius" : 20,
		"dmg" : 50
	},
	"Missile" : {
		"price" : 10,
		"radius" : 10,
		"dmg" : 80
	},
	"Armor Piercing Shell" : {
		"price" : 20,
		"radius" : 20,
		"dmg" : 180
	},
	"Shrapnel Round" : {
		"price" : 50,
		"radius" : 30,
		"dmg" : 50
	},
	"Hailfire I" : {
		"price" : 200,
		"radius" : 15,
		"dmg" : 60,
		"count" : 3
	},
	"Atom Bomb" : {
		"price" : 1000,
		"radius" : 60,
		"dmg" : 1000
	},
	"Hailfire II" : {
		"price" : 500,
		"radius" : 20,
		"dmg" : 80,
		"count" : 4
	},
	"Laser Beam I" : {
		"price" : 600,
		"radius" : 0,
		"dmg" : 800,
		"ticks" : 30
	},
	"Hydrogen Bomb" : {
		"price" : 1400,
		"radius" : 120,
		"dmg" : 2000
	},
	"Hailfire III" : {
		"price" : 1500,
		"radius" : 30,
		"dmg" : 100,
		"count" : 6
	},
	"Laser Beam II" : {
		"price" : 1600,
		"radius" : 30,
		"dmg" : 1000,
		"ticks" : 30
	},
	"Hailfire IV" : {
		"price" : 1800,
		"radius" : 50,
		"dmg" : 500,
		"count" : 10
	},
	"Laser Beam III" : {
		"price" : 2000,
		"radius" : 40,
		"dmg" : 1100,
		"ticks" : 60
	},
	"Airstrike I" : {
		"price" : 2000,
		"radius" : 30,
		"dmg" : 400,
		"count" : 5
	},
	"Airstrike II" : {
		"price" : 3000,
		"radius" : 50,
		"dmg" : 800,
		"count" : 11
	},
	"Space Laser" : {
		"price" : 3200,
		"radius" : 40,
		"dmg" : 1000
	}
}

var _loaded = false

func isTargetedWeapon(name):
	return "Airstrike" in name or name == "Space Laser"

func fireWeapon(tree, name, angle, firepower, pos, src):
	if name in STANDARD_WEAPONS:
		var velocity = Vector2(
			cos(angle), sin(angle)
		) * firepower * 20
		var projectile = projObj.instance()
		projectile.position = pos
		tree.add_child(projectile)
		projectile.init(
			WEAPON_PROPERTIES[name]["radius"],
			velocity,
			name in LARGE_EXPLOSIONS,
			src
		)
	elif "Airstrike" in name:
		pass
	elif name == "Space Laser":
		pass
	elif name == "Shrapnel Shot":
		pass
	elif "Hailfire" in name:
		pass
	elif "Laser Beam" in name:
		pass

func _enter_tree():
	if Weapons._loaded:
		printerr("Error: Weapons is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + get_path())
	else:
		Weapons._loaded = true
