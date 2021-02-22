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

func resetState():
	hasFired = false
	turnEnded = false

func endTurn():
	turnEnded = true
	# TODO: remove weapons for which the count is 0

func isTeammate(tank):
	if team == "":
		return false
	return team == tank.team

func rotate(angle):
	firingAngle += deg2rad(angle)
	firingAngle = clamp(firingAngle, -PI, 0)
	if !barrelRotation.playing:
		barrelRotation.play()
	update()

func _draw():
	# Draw tank barrel
	var barrel = Rect2(0, -3, 20, 6)
	draw_set_transform(Vector2(0, -2), firingAngle, Vector2.ONE)
	draw_rect(barrel, Color.black)
	draw_set_transform_matrix(Transform2D.IDENTITY)

func _process(_delta):
	if !isActiveTank:
		return

	if Input.is_action_pressed("ui_down") and firingAngle > -PI:
		rotate(-1)
	elif Input.is_action_pressed("ui_up") and firingAngle < 0:
		rotate(1)

	if Input.is_action_pressed("ui_page_up"):
		firepower = clamp(firepower + 1, 0, 100)
	elif Input.is_action_pressed("ui_page_down"):
		firepower = clamp(firepower - 1, 0, 100)

	if Input.is_action_just_pressed("fire"):
		pass

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
