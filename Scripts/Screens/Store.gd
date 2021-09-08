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

onready var storeItem = preload("res://Scenes/UI/Store Item.tscn")

onready var tree = get_tree()

onready var weapons = $Categories/Weapons
onready var upgrades = $Categories/Items/Upgrades
onready var items = $Categories/Items/Items

onready var skipCCs = $"Controls/Keep Playing/Skip CCs"
onready var nextBtn = $"Controls/Keep Playing/Next Player"

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
		if name == "Hill Climbing":
			continue
		var data = Items.UPGRADE_PROPERTIES[name]
		var entry = storeItem.instance()
		upgrades.add_child(entry)
		itemSetup(entry, name, "Upgrade", data["price"])

	for name in Items.ITEM_PROPERTIES:
		var data = Items.ITEM_PROPERTIES[name]
		var entry = storeItem.instance()
		items.add_child(entry)
		itemSetup(entry, name, "Item", data["price"])

	skipCCs.pressed = Globals.gameSettings["storeSkipCCs"]

	var shouldSkip = false
	if skipCCs.pressed:
		var humansExist = false
		for player in Globals.players:
			if !player.isCC:
				humansExist = true
				break
		shouldSkip = Globals.players[0].isCC and humansExist

	if shouldSkip:
		nextPlayer()
	else:
		setPlayer(0)
	updateNextText()

func refreshBalance():
	$"Player Stats/Player Money".text = "($%d)" % Globals.players[currentPlayer].money

func setPlayer(num):
	var player = Globals.players[num]
	$"Player Stats/Player Color".color = player.color
	$"Player Stats/Player Name".text = player.tankName
	$"Player Stats/Player Money".text = "($%d)" % player.money
	emit_signal("refresh", player)

func nextPlayer():
	var player = Globals.players[currentPlayer]
	if player.isCC:
		player.makePurchases()
	if currentPlayer + 1 >= len(Globals.players):
		Globals.gameSettings["storeSkipCCs"] = skipCCs.pressed
		Globals.saveSettings()
		tree.change_scene("res://Scenes/Screens/Game.tscn")
	else:
		currentPlayer += 1
		player = Globals.players[currentPlayer]
		if player.isCC and skipCCs.pressed:
			nextPlayer()
		else:
			setPlayer(currentPlayer)
		updateNextText()

func saveTank():
	var player = Globals.players[currentPlayer]
	# CC tanks make purchases pre-saving since otherwise the last tank
	# would not be able to purchase things before leaving the store
	if player.isCC:
		player.makePurchases()
	player.writeToDisk()

func updateNextText():
	nextBtn.text = getNextText()

func getNextText():
	var nextIndex = currentPlayer + 1
	var playerCount = len(Globals.players)
	if nextIndex >= playerCount:
		return "Next round"
	if !skipCCs.pressed:
		return "Next player"
	for i in range(nextIndex, playerCount):
		var player = Globals.players[i]
		if !player.isCC:
			return "Next player"
	return "Next round"
