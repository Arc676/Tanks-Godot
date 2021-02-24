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

extends HBoxContainer

var player
var type

signal itemPurchased

func makeHeaderRow():
	$Name.text = "Name"
	$Price.text = "Price"
	$Owned.text = "Qty Owned"
	$Buy.visible = false

# warning-ignore:shadowed_variable
func loadProperties(name, type, price):
	$Name.text = name
	self.type = type
	$Price.text = "$%d" % price
	$Buy.visible = true

# warning-ignore:shadowed_variable
func updateAmt(player):
	self.player = player
	if player.isCC:
		$Owned.text = "-"
	else:
		$Owned.text = "%d" % player.getAmountOwned($Name.text, type)


func buyItem():
	if player.isCC:
		return
	player.purchaseItem($Name.text, type, int($Price.text))
	$Owned.text = "%d" % player.getAmountOwned($Name.text, type)
	emit_signal("itemPurchased")
