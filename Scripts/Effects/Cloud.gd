extends RigidBody2D

onready var sprite = $Sprite

func _integrate_forces(state):
	if position.x < -10 * sprite.scale.x:
		state.transform = Transform2D(
			0,
			Vector2(Globals.SCR_WIDTH, position.y)
		)
	elif position.x > Globals.SCR_WIDTH:
		state.transform = Transform2D(
			0,
			Vector2(-10 * sprite.scale.x, position.y)
		)
