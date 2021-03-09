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

extends PopupDialog

signal confirmed(tankName)

onready var selection = $VBoxContainer/Selection

func _ready():
	selection.clear()
	for file in Globals.saveFiles:
		selection.add_item(file)

func cancelLoad():
	hide()

func confirmLoad():
	emit_signal("confirmed", selection.items[selection.selected])
	hide()
