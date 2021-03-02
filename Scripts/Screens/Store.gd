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

onready var storeItem = preload("res://Scenes/UI/Store Item.tscn")

onready var tree = get_tree()

onready var weapons = $Categories/Weapons
onready var upgrades = $Categories/Items/Upgrades
onready var items = $Categories/Items/Items

var currentPlayer = 0

signal refresh(player)

func itemSetup(entry, name, type, price):
	entry.loadProperties(name, type, price)
	# warning-ignore:return_value_discarded
	self.connect("refresh", entry, "updateAmt")
	entry.connect("itemPurchased", self, "refreshBalance")

func _ready():
	var weaponHeader = storeItem.instance()
	weapons.add_child(weaponHeader)
	weaponHeader.makeHeaderRow()
	for name in Weapons.WEAPON_PROPERTIES:
		if name == "Tank Shell":
			continue
		var data = Weapons.WEAPON_PROPERTIES[name]
		var entry = storeItem.instance()
		weapons.add_child(entry)
		itemSetup(entry, name, "Ammo", data["price"])

	var upgradeHeader = storeItem.instance()
	upgrades.add_child(upgradeHeader)
	upgradeHeader.makeHeaderRow()
	for name in Items.UPGRADE_PROPERTIES:
		var data = Items.UPGRADE_PROPERTIES[name]
		var entry = storeItem.instance()
		upgrades.add_child(entry)
		itemSetup(entry, name, "Upgrade", data["price"])

	for name in Items.ITEM_PROPERTIES:
		var data = Items.ITEM_PROPERTIES[name]
		var entry = storeItem.instance()
		items.add_child(entry)
		itemSetup(entry, name, "Item", data["price"])

	setPlayer(0)

func refreshBalance():
	$"Player Stats/Player Money".text = "($%d)" % Globals.players[currentPlayer].money

func setPlayer(num):
	var player = Globals.players[num]
	$"Player Stats/Player Color".color = player.color
	$"Player Stats/Player Name".text = player.tankName
	$"Player Stats/Player Money".text = "($%d)" % player.money
	emit_signal("refresh", player)

func nextPlayer():
	if currentPlayer + 1 >= len(Globals.players):
		tree.change_scene("res://Scenes/Screens/Game.tscn")
	else:
		currentPlayer += 1
		setPlayer(currentPlayer)

func saveTank():
	Globals.players[currentPlayer].writeToDisk()

func backToMain():
	tree.change_scene("res://Scenes/Screens/Main Menu.tscn")
