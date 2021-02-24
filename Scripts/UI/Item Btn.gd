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

extends TextureButton

# Textures
onready var textures = {
	"Repair Kit" : preload("res://Sprites/RepairKit.png"),
	"Teleport" : preload("res://Sprites/Teleport.png"),
	"Weak Shield" : preload("res://Sprites/Weak Shield.png"),
	"Medium Shield" : preload("res://Sprites/Medium Shield.png"),
	"Strong Shield" : preload("res://Sprites/Strong Shield.png"),
	"Ultimate Shield" : preload("res://Sprites/Ultimate Shield.png")
}

var player
var itemName

func init(name, tank):
	texture_normal = textures[name]
	itemName = name
	player = tank
	var amt = tank.getAmountOwned(name, "Item")
	if "Shield" in name:
		if player.activeShield:
			hint_tooltip = "Can't activate shield now"
		else:
			hint_tooltip = "Activate %s (%d)" % [name, amt]
	else:
		hint_tooltip = "%s%s (%d)" % [
			"" if name == "Teleport" else "Use ",
			name,
			amt
		]

func itemUsed():
	player.useItem(itemName)
