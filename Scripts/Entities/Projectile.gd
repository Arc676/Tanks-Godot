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

extends RigidBody2D
class_name Projectile

onready var projObj = load("res://Scenes/Entities/Projectile.tscn")

onready var explosion = preload("res://Scenes/Effects/Explosion.tscn")
onready var exBig = preload("res://Sound/ex_large.wav")
onready var exSmall = preload("res://Sound/ex_small.wav")

onready var sound = $AudioStreamPlayer2D

var impactMutex = Mutex.new()
var hasImpacted = false

var blastRadius
var damage
var srcPlayer
var isShrapnelRound

func init(properties, velocity, isBig, src):
	blastRadius = properties.radius
	damage = properties.dmg
	linear_velocity = velocity
	srcPlayer = src
	if isBig:
		sound.stream = exBig
	else:
		sound.stream = exSmall

	# Check if spawned inside terrain
	if isInTerrain():
		call_deferred("impact", Weapons.terrain)

# By default, check if the projectile (radius 5) is touching the terrain
func isInTerrain(dy = -5):
	var terrainHeight = Weapons.terrain.heightAtX(position.x)
	# Remember that Godot's Y axis points down
	if position.y > terrainHeight + dy:
		return true
	return false

func _draw():
	draw_circle(Vector2.ZERO, 5, Color.black)

func _physics_process(delta):
	add_central_force(Vector2.RIGHT * Weapons.terrain.windSpeed * 500 * delta)

func despawn():
	Weapons.changeProjCount(-1)
	queue_free()

func _process(_delta):
	if position.x < 0 or position.x > Globals.SCR_WIDTH \
		or position.y > Globals.SCR_HEIGHT:
		despawn()
		return
	if hasImpacted:
		if !sound.playing:
			despawn()
		return
	# If moving quickly, do a quick collision check
	if linear_velocity.length() > 500 and isInTerrain(10):
		impact(Weapons.terrain)

func impact(_body):
	impactMutex.lock()
	if hasImpacted:
		impactMutex.unlock()
		return
	hasImpacted = true
	impactMutex.unlock()
	var boom = explosion.instance()
	boom.position = position
	get_parent().add_child(boom)
	boom.init(true, blastRadius)
	sound.play()
	Weapons.terrain.deform(blastRadius, position.x)

	for tank in Globals.players:
		if tank.hp > 0:
			var dist = (position - tank.position).length()
			if !srcPlayer.isCC or Globals.gameSettings["scaleForCCs"]:
				dist /= Globals.gameSettings["scaleDmgDist"]
			if dist < blastRadius:
				var score = 2 * floor(50 * blastRadius / max(1, dist))
				var dmg = damage / pow(dist / 20, 2) if dist > 20 else damage * 1.5
				tank.takeDamage(dmg)
				if tank.hp <= 0:
					score *= 2
				if tank == srcPlayer or tank.isTeammate(srcPlayer):
					score *= -1
				else:
					srcPlayer.money += round(score * 1.5)
				srcPlayer.score += score

	if isShrapnelRound:
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		Weapons.changeProjCount(4)
		for _i in range(4):
			var projectile = projObj.instance()
			var velocity = Vector2(
				rng.randf_range(-200, 200),
				rng.randf_range(-200, 0)
			)
			projectile.position = position + 5 * Vector2.UP
			get_parent().call_deferred("add_child", projectile)
			projectile.call_deferred(
				"init",
				{
					"radius" : blastRadius,
					"dmg" : damage / 4
				},
				velocity,
				false,
				srcPlayer
			)
	visible = false
