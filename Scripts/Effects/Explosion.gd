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

extends Sprite

# Textures
onready var explosionSprite = preload("res://Sprites/Explosion.png")
onready var teleportSprite = preload("res://Sprites/TeleportSphere.png")

# Properties
var limit

# State
var ticks = 0

func init(isExplosion, expLimit):
	if isExplosion:
		texture = explosionSprite
	else:
		texture = teleportSprite
	limit = expLimit

func _process(delta):
	ticks += 2 * limit * delta
	var ds = 2 * (limit - ticks) if ticks > limit / 2 else 2 * ticks
	scale = Vector2(ds / 50, ds / 50)
	if ticks > limit:
		queue_free()
