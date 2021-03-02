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

extends Area2D

var shieldName
var color
var hp
var limit
var tank

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func init(shieldName, shieldHP, shieldColor, tank):
	self.shieldName = shieldName
	self.tank = tank
	color = shieldColor
	hp = shieldHP
	limit = hp

func getShieldPercentage():
	return float(hp) / limit

func takeDamage(dmg):
	hp -= dmg
	update()
	if hp <= 0:
		return abs(hp)
	return null

func _draw():
	if tank.hp <= 0:
		return
	var c = color
	c.a = getShieldPercentage()
	draw_arc(position, 30, 0, 2 * PI, 1000, c, 5, true)
	pass
