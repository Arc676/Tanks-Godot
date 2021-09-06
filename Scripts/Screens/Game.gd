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

extends Control

onready var tree = get_tree()

onready var itemBtn = preload("res://Scenes/UI/Item Btn.tscn")

onready var muteTexture = preload("res://Textures/UI/mute_0.png")
onready var unmuteTexture = preload("res://Textures/UI/unmute_0.png")

# HUD - Player data
onready var pColor = $"ColorRect/HUD/Player Stats/Identification/Player Color"
onready var pName = $"ColorRect/HUD/Player Stats/Identification/Player Name"
onready var pHP = $"ColorRect/HUD/Player Stats/HBoxContainer/Bars/Health Bar"
onready var pFirepower = $"ColorRect/HUD/Player Stats/HBoxContainer/Bars/Firepower Bar"
onready var pFuel = $"ColorRect/HUD/Player Stats/HBoxContainer/Bars/Fuel Bar"

# HUD - Weapon
onready var weaponName = $"ColorRect/HUD/Weapon, Items/Current Weapon/Weapon Name"
onready var availableAmmo = $"ColorRect/HUD/Weapon, Items/Current Weapon/Ammo"

# HUD - Items
onready var shieldState = $"ColorRect/HUD/Weapon, Items/Shield State"
onready var pItems = $"ColorRect/HUD/Weapon, Items/Items"

# HUD - Terrain data
onready var windL = $"ColorRect/HUD/Wind/Bars/Wind Bar L"
onready var windR = $"ColorRect/HUD/Wind/Bars/Wind Bar R"

# HUD - Scoreboard
onready var scores = [
	$"ColorRect/HUD/Scoreboard/Score 1",
	$"ColorRect/HUD/Scoreboard/Score 2",
	$"ColorRect/HUD/Scoreboard/Score 3",
	$"ColorRect/HUD/Scoreboard/Score 4"
]

# Game
var activePlayer = 0
var players = []
var drawDeclared = false
onready var terrain = $"Game Scene/Terrain"

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	Weapons.airstrikeSound = $"Game Scene/Bomber"
	Weapons.terrain = terrain

	players = []
	drawDeclared = false

	$"Touch Controls".visible = Globals.gameSettings.touchUI

	var muted = !Globals.gameSettings.sfx
	setSFXBtnTexture(muted)
	AudioServer.set_bus_mute(1, muted)

	var touchNextWeapon = $"Touch Controls/UI Left/Weapons/NextWeapon"
	var touchPrevWeapon = $"Touch Controls/UI Left/Weapons/PrevWeapon"

	terrain.generateNewTerrain(Globals.selectedTerrain,
		Globals.SCR_HEIGHT,
		Globals.SCR_WIDTH)
	var z = 1
	var occupiedSpawns = []
	for tank in Globals.players:
		tank.reset()

		var idx = rng.randi_range(4, terrain.chunkCount - 4)
		while idx in occupiedSpawns:
			idx = rng.randi_range(4, terrain.chunkCount - 4)
		occupiedSpawns.append(idx)
		tank.position = terrain.ground.polygon[idx] + Vector2.UP * 3

		tank.terrain = terrain

		tank.touchMoveLeft = $"Touch Controls/UI Left/Buttons/Move Left"
		tank.touchMoveRight = $"Touch Controls/UI Left/Buttons/Move Right"
		tank.touchCW = $"Touch Controls/UI Left/Buttons/CW"
		tank.touchCCW = $"Touch Controls/UI Left/Buttons/CCW"
		tank.touchFirepowerUp = $"Touch Controls/UI Left/Buttons/Firepower Up"
		tank.touchFirepowerDown = $"Touch Controls/UI Left/Buttons/Firepower Down"
		tank.touchFire = $"Touch Controls/Fire"

		touchNextWeapon.connect("button_up", tank, "input_changeWeapon",
			[touchNextWeapon])
		touchPrevWeapon.connect("button_up", tank, "input_changeWeapon",
			[touchPrevWeapon])

		tank.z_index = z
		z += 1

		tank.connect("itemsChanged", self, "updateItems")

		$"Game Scene".add_child(tank)
		players.append(tank)

	if Globals.gameSettings["shuffleOrder"]:
		players.shuffle()

	# Remove unused scoreboard entries
	for i in range(4):
		scores[i].visible = len(players) >= i + 1

	setActiveTank(0)
	updateHUD()

func toggleSFX():
	Globals.gameSettings.sfx = !Globals.gameSettings.sfx
	Globals.saveSettings()

	var muted = !Globals.gameSettings.sfx
	AudioServer.set_bus_mute(1, muted)

	setSFXBtnTexture(muted)

func setSFXBtnTexture(muted):
	if muted:
		$ColorRect/HUD/Controls/SFX.texture_normal = muteTexture
	else:
		$ColorRect/HUD/Controls/SFX.texture_normal = unmuteTexture

func drawGame():
	players[activePlayer].endTurn()
	for tank in players:
		if tank.hp > 0:
			tank.score += 100
			tank.money += 100
	drawDeclared = true

func gameOver():
	if drawDeclared:
		return true
	var firstSurvivor = null
	for tank in players:
		if tank.hp > 0:
			if firstSurvivor == null:
				firstSurvivor = tank
			elif !tank.isTeammate(firstSurvivor):
				return false
	return true

func updateHUD():
	if terrain.windSpeed < 0:
		windL.value = abs(terrain.windSpeed) * 100
		windR.value = 0
	else:
		windL.value = 0
		windR.value = terrain.windSpeed * 100

	for i in range(len(players)):
		var tank = players[i]
		scores[i].text = "%s: %d" % [tank.tankName, tank.score]

	updateItems()

func updateItems():
	for btn in pItems.get_children():
		btn.queue_free()
	var tank = players[activePlayer]
	for item in tank.items:
		var btn = itemBtn.instance()
		pItems.add_child(btn)
		btn.init(item, tank)

func _process(_delta):
	var activeTank = players[activePlayer]

	pHP.value = activeTank.hp
	pFirepower.value = activeTank.firepower
	pFuel.value = activeTank.fuel

	if activeTank.activeShield:
		shieldState.text = "%s at %d%%" % [
			activeTank.activeShield.shieldName,
			activeTank.activeShield.getShieldPercentage() * 100
		]
	else:
		shieldState.text = ""

	var weapon = activeTank.weapons.keys()[activeTank.selectedWeapon]
	weaponName.text = weapon
	availableAmmo.text = "%d" % activeTank.weapons[weapon]

	var turnEnded = false
	if activeTank.turnEnded:
		turnEnded = true
		activeTank.resetState()
		activePlayer = (activePlayer + 1) % len(players)
		setActiveTank(activePlayer)

		terrain.newWindSpeed()
		updateHUD()

	if turnEnded and gameOver():
		for tank in players:
			$"Game Scene".remove_child(tank)
		Weapons.clearProjectiles()
		tree.change_scene("res://Scenes/Screens/Store.tscn")

func setActiveTank(idx):
	var tank = players[idx]
	tank.isActiveTank = true
	pColor.color = tank.color
	pName.text = tank.tankName
	$"Touch Controls/UI Left/Weapons".visible = tank.weapons.size() > 1
