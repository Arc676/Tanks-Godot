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

onready var projObj = load("res://Scenes/Entities/Projectile.tscn")

onready var explosion = preload("res://Scenes/Effects/Explosion.tscn")
onready var exBig = preload("res://Sound/ex_large.wav")
onready var exSmall = preload("res://Sound/ex_small.wav")

onready var sound = $AudioStreamPlayer2D

var hasImpacted = false
var blastRadius
var srcPlayer
var isShrapnelRound

# warning-ignore:shadowed_variable
func init(blastRadius, velocity, isBig, src):
	self.blastRadius = blastRadius
	linear_velocity = velocity
	srcPlayer = src
	if isBig:
		sound.stream = exBig
	else:
		sound.stream = exSmall

func _draw():
	draw_circle(Vector2.ZERO, 5, Color.black)

func _physics_process(delta):
	add_central_force(Vector2.RIGHT * Weapons.terrain.windSpeed * 500 * delta)

func _process(_delta):
	if position.x < 0 or position.x > Globals.SCR_WIDTH \
		or position.y > Globals.SCR_HEIGHT:
		queue_free()
	if hasImpacted:
		if !sound.playing:
			queue_free()

func impact(_body):
	if hasImpacted:
		return
	var boom = explosion.instance()
	boom.position = position
	get_parent().add_child(boom)
	boom.init(true, blastRadius)
	sound.play()
	Weapons.terrain.deform(blastRadius, position.x)
	if isShrapnelRound:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		for _i in range(4):
			var projectile = projObj.instance()
			var velocity = Vector2(
				rng.randf_range(-200, 200),
				rng.randf_range(-200, 0)
			)
			projectile.position = position + 5 * Vector2.UP
			get_parent().add_child(projectile)
			projectile.init(blastRadius, velocity, false, srcPlayer)
	hasImpacted = true
	visible = false
