extends KinematicBody2D

# Sounds
onready var barrelRotation = $Barrel
onready var explosion = $Explosion
onready var teleport = $Teleportation

# Stats
var tankName = ""
var team = ""
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
var hasFired = false
var turnEnded = false
var isTargeting = false
var isFalling = false
var isTeleporting = false

func setColor(color):
	$Sprite.modulate = color

func reset():
	hp = 100
	fuel = startingFuel

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
	if Input.is_action_pressed("ui_down") and firingAngle > -PI:
		rotate(-1)
	elif Input.is_action_pressed("ui_up") and firingAngle < 0:
		rotate(1)
	if Input.is_action_pressed("ui_page_up"):
		firepower += 1
	elif Input.is_action_pressed("ui_page_down"):
		firepower -= 1
