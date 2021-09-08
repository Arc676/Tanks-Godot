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

extends StaticBody2D
class_name Terrain

enum TerrainType {
	DESERT,
	PLAINS,
	HILLS,
	RANDOM
}

const chunkCount = 41
var chunkSize = 0

var rng = RandomNumberGenerator.new()

onready var ground = $Ground
onready var cloudObj = preload("res://Scenes/Effects/Cloud.tscn")

# Terrain state
var terrainType = TerrainType.DESERT
var windSpeed = 0
var clouds = []

# Dimensions
var terrainWidth = 0
var terrainHeight = 0

func _ready():
	rng.randomize()

func getColor(type):
	if type == TerrainType.DESERT:
		return Color(0.86, 0.77, 0.26)
	elif type == TerrainType.PLAINS:
		return Color(0, 0.78, 0)
	elif type == TerrainType.HILLS:
		return Color(0, 0.67, 0)
	else:
		return Color.white

func _draw():
	draw_rect(Rect2(0, 0, terrainWidth, terrainHeight), Color(0.84, 0.92, 1))
	draw_colored_polygon(ground.polygon, getColor(terrainType))

func deviationForTerrain(type):
	if type == TerrainType.DESERT:
		return 10
	elif type == TerrainType.PLAINS:
		return 5
	elif type == TerrainType.HILLS:
		return 100
	else:
		return -1

func generateNewTerrain(type, height, width):
	if type == TerrainType.RANDOM:
		type = rng.randi_range(TerrainType.DESERT, TerrainType.HILLS)
	terrainType = type

	terrainHeight = height
	terrainWidth = width

	chunkSize = width / (chunkCount - 1)

	var points = ground.polygon
	# First control point is at least 25% of the window height and at most
	# 50% of the window height (Y-axis points downwards in Godot)
	points[0] = Vector2(0, rng.randf_range(height / 2, height * 0.75))
	var deviation = deviationForTerrain(type)
	for i in range(1, chunkCount):
		var dh = rng.randf_range(-deviation / 2, deviation / 2)
		var nextHeight = points[i - 1].y + dh
		# Ensure that the terrain is never less than 5% of the window
		# height and never more than 75% of the window height
		nextHeight = clamp(nextHeight, height * 0.25, height * 0.95)
		points[i] = Vector2(i * chunkSize, nextHeight)
	points[-2] = Vector2(width, height)
	points[-1] = Vector2(0, height)
	ground.set_polygon(points)
	update()

	newWindSpeed(true)

func newWindSpeed(random = false):
	if Globals.gameSettings.wind == Globals.WIND_SETTING.NO_WIND:
		windSpeed = 0
		return

	if random or Globals.gameSettings.wind == Globals.WIND_SETTING.RANDOM_WIND:
		windSpeed = rng.randf_range(-2, 2)
	else:
		var dev = Globals.getWindDev()
		windSpeed += rng.randf_range(windSpeed * -dev, windSpeed * dev)
	for cloud in clouds:
		cloud.queue_free()
	clouds.clear()
	for _i in range(rng.randi_range(0, 4)):
		var cloud = cloudObj.instance()
		cloud.position = Vector2(
			rng.randf_range(0, Globals.SCR_WIDTH),
			rng.randf_range(150, 175)
		)
		cloud.linear_velocity = Vector2(windSpeed * 500, 0)
		add_child(cloud)
		cloud.sprite.scale = Vector2(
			rng.randf_range(5, 20),
			rng.randf_range(2, 4)
		)
		clouds.append(cloud)

func deform(radius, x):
	var xMin = round((x - radius) / chunkSize)
	var xMax = round((x + radius) / chunkSize)
	var r2 = pow(radius, 2)

	var points = ground.polygon

	var dx = xMin - x / chunkSize
	for block in range(xMin, xMax + 1):
		if block >= 0 and block < chunkCount:
			var opp2 = pow(dx * chunkSize, 2)
			if opp2 < r2:
				points[block].y = min(
					points[block].y + sqrt(r2 - opp2),
					terrainHeight
				)
		dx += 1
	ground.set_deferred("polygon", points)
	update()
