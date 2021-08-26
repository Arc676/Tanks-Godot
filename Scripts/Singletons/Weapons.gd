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
onready var laserObj = preload("res://Scenes/Effects/Laser.tscn")

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
		"ticks" : 0.5
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
		"ticks" : 0.5
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
		"ticks" : 1
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
		"dmg" : 1000,
		"ticks" : 1
	}
}
var WEAPON_NAMES_REVERSED

var airstrikeSound
var laserSound

var projMutex = Mutex.new()
var projCount = 0

var terrain

var _loaded = false

func clearProjectiles():
	projMutex.lock()
	projCount = 0
	projMutex.unlock()

func changeProjCount(delta):
	projMutex.lock()
	projCount += delta
	projMutex.unlock()

func isTargetedWeapon(name):
	return "Airstrike" in name or name == "Space Laser"

func fireWeapon(tree, name, angle, firepower, pos, src):
	if name in STANDARD_WEAPONS or name == "Shrapnel Round":
		var velocity = Vector2(
			cos(angle), sin(angle)
		) * firepower * 20
		changeProjCount(1)
		var projectile = projObj.instance()
		projectile.position = pos
		projectile.isShrapnelRound = name == "Shrapnel Round"
		tree.add_child(projectile)
		projectile.init(
			WEAPON_PROPERTIES[name],
			velocity,
			name in LARGE_EXPLOSIONS,
			src
		)
	elif "Airstrike" in name:
		airstrikeSound.play()
		var count = WEAPON_PROPERTIES[name]["count"]
		changeProjCount(count)
		for i in range(-count / 2, count / 2 + 1):
			var projPos = Vector2(pos.x + i * 20, 0)
			var projectile = projObj.instance()
			projectile.position = projPos
			tree.add_child(projectile)
			projectile.init(
				WEAPON_PROPERTIES[name],
				Vector2.ZERO,
				true,
				src
			)
	elif "Laser" in name:
		changeProjCount(1)
		var laser = laserObj.instance()
		tree.add_child(laser)
		laser.z_index = 10
		laser.init(
			pos,
			angle,
			WEAPON_PROPERTIES[name],
			src,
			name == "Space Laser"
		)
	elif "Hailfire" in name:
		var velocity = Vector2(
			cos(angle), sin(angle)
		) * firepower * 20
		var dv = 20 * Vector2.RIGHT
		var count = WEAPON_PROPERTIES[name]["count"]
		changeProjCount(count)
		for i in range(count):
			var projectile = projObj.instance()
			projectile.position = pos
			tree.add_child(projectile)
			projectile.init(
				WEAPON_PROPERTIES[name],
				velocity + i * dv,
				name in LARGE_EXPLOSIONS,
				src
			)

func _enter_tree():
	if Weapons._loaded:
		printerr("Error: Weapons is an AutoLoad singleton and it shouldn't be instanced elsewhere.")
		printerr("Please delete the instance at: " + get_path())
	else:
		Weapons._loaded = true
		WEAPON_NAMES_REVERSED = WEAPON_PROPERTIES.keys().duplicate()
		WEAPON_NAMES_REVERSED.invert()
