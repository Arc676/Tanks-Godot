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

var tankName

func loadSave(name):
	tankName = name
	$Name.text = name
	var tank = Tank.new()
	tank.loadFromDisk(name, false)
	$Color.color = tank.color
	tank.queue_free()

func deleteSaveFile():
	var dir = Directory.new()
	dir.remove("user://tanks/%s.dat" % tankName)
	queue_free()
