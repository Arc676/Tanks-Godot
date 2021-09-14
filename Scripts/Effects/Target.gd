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

extends Sprite

onready var isTouch = OS.has_touchscreen_ui_hint()

func init():
	if OS.has_touchscreen_ui_hint():
		position = Vector2(
			Globals.SCR_WIDTH / 2,
			Globals.SCR_HEIGHT / 2
		)

func _input(event):
	if event is InputEventScreenDrag and \
		event.position.y < Globals.SCR_HEIGHT * 0.75:
		position = event.position

func _process(_delta):
	if !isTouch:
		position = get_global_mouse_position()
