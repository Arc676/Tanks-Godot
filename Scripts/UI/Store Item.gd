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

signal itemPurchased

func makeHeaderRow():
	$Name.text = "Name"
	$Type.text = "Type"
	$Price.text = "Price"
	$Owned.text = "Qty Owned"
	$Buy.visible = false

func loadProperties(name, type, price):
	$Name.text = name
	$Type.text = type
	$Price.text = "$%d" % price
	$Buy.visible = true

# warning-ignore:shadowed_variable
func updateAmt(player):
	self.player = player
	if player.isCC:
		$Owned.text = "-"
	else:
		$Owned.text = "%d" % player.getAmountOwned($Name.text, $Type.text)


func buyItem():
	if player.isCC:
		return
	player.purchaseItem($Name.text, $Type.text, int($Price.text))
	$Owned.text = "%d" % player.getAmountOwned($Name.text, $Type.text)
	emit_signal("itemPurchased")
