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

onready var beamSprite = preload("res://Sprites/LaserBeam.png")
onready var strikeSprite = preload("res://Sprites/LaserStrike.png")

onready var sound = $AudioStreamPlayer2D

# Timing control
var ticks = 0
var limit = 0

# Properties
var dmg
var radius
var srcPlayer

# Targeted strikes
var xPos = null

# Laser beams

# warning-ignore:shadowed_variable
func init(pos, damage, radius, duration, src, isStrike = false):
	if isStrike:
		xPos = pos.x
		texture = strikeSprite
		var scaleFactor = Globals.SCR_WIDTH / texture.get_size().y
		scale = Vector2(1, scaleFactor)
		position = Vector2(xPos - 20, 0)
	else:
		texture = beamSprite
	dmg = damage
	limit = duration
	srcPlayer = src
	self.radius = radius

func despawn():
	Weapons.changeProjCount(-1)
	sound.stop()
	queue_free()

func _process(delta):
	if !sound.playing:
		sound.play()
	ticks += delta
	if ticks > limit:
		despawn()
	if xPos:
		Weapons.terrain.deform(radius, xPos)
		for tank in Globals.players:
			if tank.hp > 0 and abs(tank.position.x - xPos) < 40:
				var score = 40
				tank.takeDamage(dmg)
				if tank.hp <= 0:
					score *= 2
				if tank == srcPlayer or tank.isTeammate(srcPlayer):
					score *= -1
				else:
					srcPlayer.money += score
				srcPlayer.score += 2 * score
