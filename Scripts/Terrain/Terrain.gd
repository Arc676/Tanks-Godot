extends StaticBody2D

enum TerrainType {
	DESERT,
	PLAINS,
	HILLS,
	RANDOM
}

const chunkCount = 41

var rng = RandomNumberGenerator.new()

onready var ground = $Ground

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

	var chunkSize = width / (chunkCount - 1)

	var points = ground.polygon
	points[0] = Vector2(0, rng.randf_range(height / 2, height * 0.75))
	var deviation = deviationForTerrain(type)
	for i in range(1, chunkCount):
		var dh = rng.randf_range(-deviation / 2, deviation / 2)
		var nextHeight = points[i - 1].y + dh
		nextHeight = clamp(nextHeight, height * 0.05, height * 0.75)
		points[i] = Vector2(i * chunkSize, nextHeight)
	points[-2] = Vector2(width, height)
	points[-1] = Vector2(0, height)
	ground.set_polygon(points)
	update()

	newWindSpeed()

func newWindSpeed():
	windSpeed = rng.randf_range(-2, 2)
