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

signal overlayHidden

func _ready():
	visible = Globals.gameSettings.showHelpOverlay
	$"Gameplay/Buttons/Always Show".pressed = visible
	$ColorRect.rect_size = $Gameplay.rect_size + Vector2(20, 20)
	$ColorRect.rect_position = $Gameplay.rect_position - Vector2(10, 10)

func hideOverlay():
	visible = false
	emit_signal("overlayHidden")

func toggleOverlay(pressed):
	Globals.gameSettings.showHelpOverlay = pressed
	Globals.saveSettings()
