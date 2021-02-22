extends Sprite

# Textures
onready var explosionSprite = preload("res://Sprites/Explosion.png")
onready var teleportSprite = preload("res://Sprites/TeleportSphere.png")

# Properties
var limit

# State
var ticks = 0

func init(isExplosion, expLimit):
	if isExplosion:
		texture = explosionSprite
	else:
		texture = teleportSprite
	limit = expLimit

func _process(delta):
	ticks += 2 * limit * delta
	var ds = 2 * (limit - ticks) if ticks > limit / 2 else 2 * ticks
	scale = Vector2(ds / 50, ds / 50)
	if ticks > limit:
		queue_free()
