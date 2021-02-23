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

extends KinematicBody2D

const MOVE_SPEED = 50

enum AILevel {
	EASY, MEDIUM, HARD
}

enum AIStyle {
	AGGRESSIVE, DEFENSIVE
}

onready var targetObj = preload("res://Scenes/Effects/Target.tscn")
var target

onready var explosionObj = preload("res://Scenes/Effects/Explosion.tscn")
var boom

# Computer controlled tanks
var isCC = false
var aiLvl = AILevel.EASY
var aiStyle = AIStyle.AGGRESSIVE

# Sounds
onready var barrelRotation = $Barrel
onready var explosion = $Explosion
onready var teleport = $Teleportation

# Stats
var tankName = ""
var team = ""
var color
var hp = 100
var fuel = 100
var money = 0
var score = 0

# Weapons
var selectedWeapon = 0
var weapons = {
	"Tank Shell" : 99
}

# Upgrades
var upgrades = [0, 0, 0, 0]

# Items
var activeShield = null
var items = {}

# Abilities
var maxHillClimb = 1
var engineEfficiency = 1
var startingFuel = 100
var armor = 1

# Firing
var firingAngle = 0
var firepower = 50

# Tank state
var isActiveTank = false
var hasFired = false
var turnEnded = false
var isTargeting = false
var isFalling = false
var isTeleporting = false
var velocity = Vector2.ZERO

func setColor(newColor):
	color = newColor
	$Sprite.modulate = color

func reset():
	hp = 100
	fuel = startingFuel
	$Sprite.visible = true

func resetState():
	hasFired = false
	turnEnded = false

func endTurn():
	turnEnded = true
	isActiveTank = false
	for key in weapons.keys():
		if weapons[key] == 0:
			weapons.erase(key)
			selectedWeapon = 0

func takeDamage(dmg):
	if activeShield:
		pass
	else:
		hp -= dmg / armor
	if hp <= 0:
		explode()

func isTeammate(tank):
	if team == "":
		return false
	return team == tank.team

func getNozzlePosition(dy = 0):
	var c = cos(firingAngle)
	var s = sin(firingAngle)
	return position + Vector2(
		20 * c - dy * s,
		-8 - dy * c + 20 * s
	)

func rotate(angle):
	firingAngle += deg2rad(angle)
	firingAngle = clamp(firingAngle, -PI, 0)
	if !barrelRotation.playing:
		barrelRotation.play()
	update()

func _draw():
	if hp <= 0:
		return
	# Draw tank barrel
	var barrel = Rect2(0, -3, 20, 6)
	draw_set_transform(Vector2(0, -2), firingAngle, Vector2.ONE)
	draw_rect(barrel, Color.black)
	draw_set_transform_matrix(Transform2D.IDENTITY)

func explode():
	boom = explosionObj.instance()
	boom.position = position
	get_parent().add_child(boom)
	boom.init(true, 40)
	explosion.play()
	$Sprite.visible = false
	update()

func fireProjectile(pos):
	var weapon = weapons.keys()[selectedWeapon]
	Weapons.fireWeapon(
		get_parent(),
		weapon,
		firingAngle,
		firepower,
		pos,
		self
	)
	if weapon != "Tank Shell":
		weapons[weapon] -= 1
	hasFired = true

func _process(_delta):
	if hp <= 0 and !boom:
		endTurn()
		return

	if position.y > Globals.SCR_HEIGHT - 10:
		hp = 0
		explode()

	if isActiveTank:
		if turnEnded or hasFired:
			if Weapons.projCount == 0:
				endTurn()
			return
		if isCC:
			ccUpdate()
		else:
			playerUpdate()

func ccUpdate():
	pass

func playerUpdate():
	if Input.is_action_pressed("ui_down") and firingAngle > -PI:
		rotate(-1)
	elif Input.is_action_pressed("ui_up") and firingAngle < 0:
		rotate(1)

	if Input.is_action_pressed("ui_page_up"):
		firepower = clamp(firepower + 1, 0, 100)
	elif Input.is_action_pressed("ui_page_down"):
		firepower = clamp(firepower - 1, 0, 100)

	if isTargeting:
		if Input.is_action_just_pressed("ui_cancel"):
			target.queue_free()
			isTargeting = false
		elif Input.is_action_just_pressed("click"):
			fireProjectile(get_global_mouse_position())
			target.queue_free()
			isTargeting = false
	elif Input.is_action_just_pressed("fire"):
		var weapon = weapons.keys()[selectedWeapon]
		if Weapons.isTargetedWeapon(weapon):
			isTargeting = true
			target = targetObj.instance()
			get_parent().add_child(target)
		else:
			fireProjectile(getNozzlePosition())

	if Input.is_action_just_pressed("next_weapon"):
		selectedWeapon = (selectedWeapon + 1) % weapons.size()
	elif Input.is_action_just_pressed("prev_weapon"):
		selectedWeapon -= 1
		if selectedWeapon < 0:
			selectedWeapon = weapons.size() - 1

func _physics_process(delta):
	velocity.y += Globals.GRAVITY * delta
	if isActiveTank and is_on_floor() and fuel > 0:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -MOVE_SPEED
			fuel -= 20 * delta / engineEfficiency
		elif Input.is_action_pressed("ui_right"):
			velocity.x = MOVE_SPEED
			fuel -= 20 * delta / engineEfficiency
		else:
			velocity.x = 0
	if fuel <= 0:
		velocity.x = 0
	velocity = move_and_slide(velocity, Vector2.UP, true)
	velocity.x = 0
