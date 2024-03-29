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

extends KinematicBody2D
class_name Tank

const MOVE_SPEED = 50

enum AILevel {
	EASY, MEDIUM, HARD
}

enum AIStyle {
	AGGRESSIVE, DEFENSIVE
}

signal itemsChanged

onready var targetObj = preload("res://Scenes/Effects/Target.tscn")
var target

onready var explosionObj = preload("res://Scenes/Effects/Explosion.tscn")
var boom

var terrain

# Touch controls
var touchMoveLeft
var touchMoveRight
var touchCW
var touchCCW
var touchFirepowerUp
var touchFirepowerDown

var weaponChangedLastFrame = 0
var firedLastFrame = false

# Computer controlled tanks
var isCC = false
var aiLvl = AILevel.EASY
var aiStyle = AIStyle.AGGRESSIVE
var rng = RandomNumberGenerator.new()
const WIND_COEFF = 350

var targetTank
var targetAngle
var targetFirepower: int
var needsRecalc = true

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
var upgrades = {
	"Engine Efficiency" : 0,
	"Armor" : 0,
	"Extra Fuel" : 0,
	"Hill Climbing" : 0
}

# Items
var shieldObj = preload("res://Scenes/Effects/Shield.tscn")
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

func writeToDisk():
	var dir = Directory.new()
	if !dir.dir_exists("user://tanks"):
		if dir.make_dir_recursive("user://tanks") != OK:
			return false
	var saveFile = File.new()
	saveFile.open("user://tanks/%s.dat" % tankName, File.WRITE)

	var weaponsCopy = weapons.duplicate()
	weaponsCopy.erase("Tank Shell")
	for property in [
		weaponsCopy, items, team, color.to_html(false), money, score
	]:
		saveFile.store_var(property)

	for upgrade in ["Engine Efficiency", "Armor", "Extra Fuel", "Hill Climbing"]:
		saveFile.store_var(upgrades[upgrade])

	saveFile.store_var(isCC)
	if isCC:
		saveFile.store_var({
			"style" : aiStyle,
			"lvl" : aiLvl
		})
	if is_instance_valid(activeShield):
		saveFile.store_var({
			"name" : activeShield.shieldName,
			"hp" : activeShield.hp
		})
	saveFile.close()
	return true

# warning-ignore:shadowed_variable
func loadFromDisk(tankName, isInTree = true):
	self.tankName = tankName
	var saveFile = File.new()
	var path = "user://tanks/%s.dat" % tankName
	if saveFile.file_exists(path):
		saveFile.open(path, File.READ)

		var additionalWeapons = saveFile.get_var()
		for weapon in additionalWeapons:
			weapons[weapon] = additionalWeapons[weapon]

		items = saveFile.get_var()
		team = saveFile.get_var()
		if isInTree:
			setColor(Color(saveFile.get_var()))
		else:
			color = Color(saveFile.get_var())
		money = saveFile.get_var()
		score = saveFile.get_var()

		for upgrade in ["Engine Efficiency", "Armor", "Extra Fuel", "Hill Climbing"]:
			var qty = saveFile.get_var()
			upgrades[upgrade] = qty
			installUpgrade(upgrade, qty)

		isCC = saveFile.get_var()
		if isCC:
			var data = saveFile.get_var()
			aiStyle = data["style"]
			aiLvl = data["lvl"]

		if saveFile.get_position() != saveFile.get_len():
			var shieldData = saveFile.get_var()
			activeShield = shieldObj.instance()
			var name = shieldData["name"]
			activeShield.init(
				name,
				Items.ITEM_PROPERTIES[name],
				self
			)
			activeShield.hp = shieldData["hp"]
			add_child(activeShield)

		saveFile.close()
		return true
	return false

func setColor(newColor):
	color = newColor
	$Sprite.modulate = color

func reset():
	hp = 100
	fuel = startingFuel
	isActiveTank = false
	$Sprite.visible = true
	velocity = Vector2.ZERO
	targetTank = null
	resetState()

func resetState():
	hasFired = false
	turnEnded = false

func endTurn():
	turnEnded = true
	isActiveTank = false
	var toDelete = []
	for key in weapons.keys():
		if weapons[key] == 0:
			toDelete.append(key)
			selectedWeapon = 0
	for key in toDelete:
		weapons.erase(key)

func installUpgrade(name, times = 1):
	var effect = Items.UPGRADE_PROPERTIES[name]["effect"]
	if name == "Engine Efficiency":
		engineEfficiency *= pow(effect, times)
	elif name == "Armor":
		armor *= pow(effect, times)
	elif name == "Hill Climbing":
		maxHillClimb *= pow(effect, times)
	else:
		startingFuel += effect * times

func makePurchases():
	# No items on easy mode
	if !isCC or aiLvl == AILevel.EASY:
		return
	# Only high level, defensive CC tanks save money
	if aiLvl == AILevel.HARD and aiStyle == AIStyle.DEFENSIVE and money < 1000:
		return
	if aiStyle == AIStyle.DEFENSIVE:
		purchaseItem("Armor", "Upgrade", Items.UPGRADE_PROPERTIES["Armor"]["price"])
		var itemCount = Items.ITEM_PROPERTIES.keys().size()
		var shields = Items.ITEM_PROPERTIES.keys().slice(-4, itemCount - 1)
		shields.invert()
		for shield in shields:
			var price = Items.ITEM_PROPERTIES[shield]["price"]
			while money >= price and getAmountOwned(shield, "Item") < 3:
					purchaseItem(shield, "Item", price)
	for weapon in Weapons.WEAPON_NAMES_REVERSED:
		if weapon == "Tank Shell" or "Laser" in weapon or Weapons.isTargetedWeapon(weapon):
			continue
		var price = Weapons.WEAPON_PROPERTIES[weapon]["price"]
		while money >= price:
			purchaseItem(weapon, "Ammo", price)

func purchaseItem(name, type, price):
	if money >= price:
		money -= price
		if type == "Ammo":
			weapons[name] = weapons.get(name, 0) + 1
		elif type == "Upgrade":
			upgrades[name] += 1
			installUpgrade(name)
		elif type == "Item":
			items[name] = items.get(name, 0) + 1

func useItem(name):
	if not name in items:
		return
	if name == "Repair Kit":
		hp += Items.ITEM_PROPERTIES[name]["hp"]
	elif name == "Teleport":
		startTargeting()
		isTeleporting = true
	elif "Shield" in name:
		if is_instance_valid(activeShield):
			return
		activeShield = shieldObj.instance()
		activeShield.init(
			name,
			Items.ITEM_PROPERTIES[name],
			self
		)
		add_child(activeShield)
	items[name] -= 1
	if items[name] == 0:
		items.erase(name)
	emit_signal("itemsChanged")

func getAmountOwned(name, type):
	if type == "Ammo":
		return weapons.get(name, 0)
	elif type == "Upgrade":
		return upgrades[name]
	elif type == "Item":
		return items.get(name, 0)

func destroyShield():
	activeShield.queue_free()

func takeDamage(dmg):
	if is_instance_valid(activeShield):
		var excess = activeShield.takeDamage(dmg)
		if excess == 0:
			return
		destroyShield()
		dmg = excess
	hp -= dmg / armor
	if hp <= 0:
		explode()

func isTeammate(tank):
	if team == "":
		return false
	return team == tank.team

func getNozzlePosition():
	var c = cos(firingAngle)
	var s = sin(firingAngle)
	return position + Vector2(
		20 * c,
		20 * s - 2
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

func startTargeting():
	isTargeting = true
	target = targetObj.instance()
	target.init()
	get_parent().add_child(target)

func stopTargeting():
	target.queue_free()
	isTargeting = false

func explode():
	boom = explosionObj.instance()
	boom.position = position
	get_parent().add_child(boom)
	boom.init(true, 40)
	explosion.play()
	$Sprite.visible = false
	update()
	if is_instance_valid(activeShield):
		activeShield.update()

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
	if isCC:
		needsRecalc = true
		if !is_instance_valid(activeShield):
			var itemCount = Items.ITEM_PROPERTIES.keys().size()
			var shields = Items.ITEM_PROPERTIES.keys().slice(-4, itemCount - 1)
			shields.invert()
			for shield in shields:
				if getAmountOwned(shield, "Item") > 0:
					useItem(shield)
					break

func _process(_delta):
	if hp <= 0:
		if !is_instance_valid(boom):
			endTurn()
		return

	if position.y > Globals.SCR_HEIGHT - 20:
		hp = 0
		explode()
		return

	if isActiveTank:
		if turnEnded or hasFired:
			if Weapons.projCount == 0:
				endTurn()
			return
		if isCC:
			ccUpdate()
		else:
			playerUpdate()

# warning-ignore:shadowed_variable
func recalculate(target):
	var nozzle = getNozzlePosition()
	var x = target.x - nozzle.x
	var y = -(target.y - nozzle.y)

	var b = (y / -x) - x
	var a1 = 0.001

	var chunkRange
	var posChunk = floor(position.x / Weapons.terrain.chunkSize)
	var targetChunk = floor(target.x / Weapons.terrain.chunkSize)
	if abs(posChunk - targetChunk) >= 2:
		if x < 0:
			chunkRange = range(targetChunk + 1, posChunk)
		else:
			chunkRange = range(posChunk + 1, targetChunk)

		for i in chunkRange:
			var xc = i * Weapons.terrain.chunkSize - position.x
			var h = -(Weapons.terrain.ground.polygon[i].y - position.y)
			if -a1 * xc * (xc + b) < h:
				a1 = -(h + 7) / (xc * (xc + b))

	targetAngle = -atan(-a1 * b)
	if x < 0:
		targetAngle -= PI

	# Hard level CC tanks calculate twice to account for the nozzle moving
	if aiLvl == AILevel.HARD and needsRecalc:
		needsRecalc = false
		return recalculate(target)

	var s = -sin(targetAngle)
	var c = cos(targetAngle)
	var sc = s * c

	var den1 = 2 * Weapons.terrain.windSpeed * WIND_COEFF * (x * s * s - y * sc)
	var den2 = 2 * 981 * (x * sc - y * c * c)

	if den1 + den2 < 0:
		targetFirepower = 100
	else:
		# warning-ignore:narrowing_conversion
		targetFirepower = round(abs(
			(Weapons.terrain.windSpeed * WIND_COEFF * y + 981 * x) / sqrt(den1 + den2)
		)) / 20 + 4

	targetAngle = clamp(targetAngle, -PI, 0)
	if targetFirepower > 100:
		targetFirepower = 100
		return false

	# Hard level CC tanks avoid wasting good weapons on near-impossible shots
	if aiLvl == AILevel.HARD and targetFirepower == 100:
		selectedWeapon = 0
	else:
		selectedWeapon = weapons.keys().size() - 1

	needsRecalc = false
	return true

func chooseNewTarget():
	targetTank = null
	var possibleTargets = []
	for tank in Globals.players:
		if tank != self and tank.hp > 0 and !isTeammate(tank):
			possibleTargets.append(tank)
	if possibleTargets.size() == 0:
		return
	rng.randomize()
	while true:
		var idx = rng.randi_range(0, possibleTargets.size() - 1)
		targetTank = possibleTargets[idx]
		if possibleTargets.size() == 1 or recalculate(targetTank.position):
			break
		possibleTargets.remove(idx)

func ccUpdate():
	if !targetTank or targetTank.hp <= 0:
		chooseNewTarget()
		if !targetTank:
			endTurn()
			return
	if needsRecalc:
		if !recalculate(targetTank.position):
			chooseNewTarget()
			if !targetTank:
				endTurn()
				return
	if abs(targetAngle - firingAngle) <= deg2rad(2):
		firingAngle = targetAngle
		update()
		if firepower == targetFirepower:
			fireProjectile(getNozzlePosition())
		else:
			if firepower < targetFirepower:
				firepower += 1
			else:
				firepower -= 1
	else:
		if firingAngle < targetAngle:
			rotate(1)
		else:
			rotate(-1)

func playerUpdate():
	if input_CW() and firingAngle < 0:
		rotate(1)
	elif input_CCW() and firingAngle > -PI:
		rotate(-1)

	if input_firepowerUp():
		firepower = clamp(firepower + 1, 0, 100)
	elif input_firepowerDown():
		firepower = clamp(firepower - 1, 0, 100)

	if isTargeting:
		if input_cancelTarget():
			stopTargeting()
			if isTeleporting:
				items["Teleport"] = items.get("Teleport", 0) + 1
				isTeleporting = false
				emit_signal("itemsChanged")
		elif input_confirmTarget():
			if isTeleporting:
				var destination = get_global_mouse_position()
				var chunk = floor(destination.x / terrain.chunkSize)
				var x0 = chunk * terrain.chunkSize
				var y0 = terrain.ground.polygon[chunk].y
				var y1 = terrain.ground.polygon[chunk + 1].y
				destination.y = lerp(
					y0, y1,
					(destination.x - x0) / terrain.chunkSize
				) - 1

				var srcTP = explosionObj.instance()
				var dstTP = explosionObj.instance()

				srcTP.z_index = 10
				dstTP.z_index = 10

				srcTP.position = position
				dstTP.position = destination

				get_parent().add_child(srcTP)
				get_parent().add_child(dstTP)

				srcTP.init(false, 40)
				dstTP.init(false, 40)

				teleport.play()

				position = destination
				isTeleporting = false
				endTurn()
			else:
				fireProjectile(target.position)
			stopTargeting()
			hasFired = true
	elif input_fire():
		var weapon = weapons.keys()[selectedWeapon]
		if Weapons.isTargetedWeapon(weapon):
			startTargeting()
		else:
			fireProjectile(getNozzlePosition())

	if input_nextWeapon():
		selectedWeapon = (selectedWeapon + 1) % weapons.size()
	elif input_prevWeapon():
		selectedWeapon -= 1
		if selectedWeapon < 0:
			selectedWeapon = weapons.size() - 1

	weaponChangedLastFrame = 0
	firedLastFrame = false

func _physics_process(delta):
	velocity.y += Globals.GRAVITY * delta
	if !isCC and isActiveTank and !hasFired and is_on_floor() and fuel > 0:
		if input_moveLeft():
			velocity.x = -MOVE_SPEED
			fuel -= 20 * delta / engineEfficiency
		elif input_moveRight():
			velocity.x = MOVE_SPEED
			fuel -= 20 * delta / engineEfficiency
		else:
			velocity.x = 0
	if fuel <= 0:
		velocity.x = 0
	velocity = move_and_slide(velocity, Vector2.UP, true)
	velocity.x = 0

func input_moveLeft():
	return Input.is_action_pressed("ui_left") or touchMoveLeft.pressed

func input_moveRight():
	return Input.is_action_pressed("ui_right") or touchMoveRight.pressed

func input_firepowerUp():
	return Input.is_action_pressed("ui_page_up") or touchFirepowerUp.pressed

func input_firepowerDown():
	return Input.is_action_pressed("ui_page_down") or touchFirepowerDown.pressed

func input_CCW():
	return (Input.is_action_pressed("ui_down") and \
			!Input.is_action_pressed("ui_page_down")) \
		or touchCCW.pressed

func input_CW():
	return (Input.is_action_pressed("ui_up") and \
			!Input.is_action_pressed("ui_page_up")) \
		or touchCW.pressed

func input_fire():
	return Input.is_action_just_pressed("fire") or firedLastFrame

func input_nextWeapon():
	return Input.is_action_just_pressed("next_weapon") or weaponChangedLastFrame > 0

func input_prevWeapon():
	return Input.is_action_just_pressed("prev_weapon") or weaponChangedLastFrame < 0

# Called when ammo changing touch controls are released
func input_changeWeapon(btn):
	if !isActiveTank:
		return
	if btn.name == "PrevWeapon":
		weaponChangedLastFrame = -1
	else:
		weaponChangedLastFrame = 1

# Called when firing touch control is released
func input_touchFire():
	if !isActiveTank:
		return
	firedLastFrame = true

func input_cancelTarget():
	return Input.is_action_just_pressed("ui_cancel") or weaponChangedLastFrame != 0

func input_confirmTarget():
	return Input.is_action_just_pressed("click") or (
		firedLastFrame and
		target.position.y < Globals.SCR_HEIGHT * 0.75 and
		target.position.y > Globals.SCR_HEIGHT * 0.25
	)
