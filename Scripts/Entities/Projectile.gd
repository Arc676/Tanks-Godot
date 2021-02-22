extends RigidBody2D

onready var explosion = preload("res://Scenes/Effects/Explosion.tscn")
onready var exBig = preload("res://Sound/ex_large.wav")
onready var exSmall = preload("res://Sound/ex_small.wav")

onready var sound = $AudioStreamPlayer2D

var hasImpacted = false
var blastRadius

# warning-ignore:shadowed_variable
func init(blastRadius, velocity, isBig = false):
	self.blastRadius = blastRadius
	linear_velocity = velocity
	if isBig:
		sound.stream = exBig
	else:
		sound.stream = exSmall

func _draw():
	draw_circle(position, 5, Color.black)

func _process(_delta):
	if position.x < 0 or position.x > Globals.SCR_WIDTH \
		or position.y > Globals.SCR_HEIGHT:
		queue_free()
	if hasImpacted:
		if !sound.playing:
			queue_free()

func impact(_body):
	var boom = explosion.instance()
	boom.position = position
	boom.init(true, self.blastRadius)
	get_tree().add_child(boom)
	sound.play()
	hasImpacted = true
