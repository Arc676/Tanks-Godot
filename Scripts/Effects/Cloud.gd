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

extends RigidBody2D

onready var sprite = $Sprite

func _integrate_forces(state):
	if position.x < -10 * sprite.scale.x:
		state.transform = Transform2D(
			0,
			Vector2(Globals.SCR_WIDTH, position.y)
		)
	elif position.x > Globals.SCR_WIDTH:
		state.transform = Transform2D(
			0,
			Vector2(-10 * sprite.scale.x, position.y)
		)
