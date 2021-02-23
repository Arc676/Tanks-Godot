extends Control

onready var storeItem = preload("res://Scenes/UI/Store Item.tscn")

onready var tree = get_tree()

var currentPlayer = 0

signal refresh(player)

func _ready():
	for name in Weapons.WEAPON_PROPERTIES:
		if name == "Tank Shell":
			continue
		var data = Weapons.WEAPON_PROPERTIES[name]
		var entry = storeItem.instance()
		$Categories/Weapons.add_child(entry)
		entry.loadProperties(name, "Ammo", data["price"])
		# warning-ignore:return_value_discarded
		self.connect("refresh", entry, "updateAmt")
		entry.connect("itemPurchased", self, "refreshBalance")
	setPlayer(0)

func refreshBalance():
	$"Player Stats/Player Money".text = "($%d)" % Globals.players[currentPlayer].money

func setPlayer(num):
	var player = Globals.players[num]
	$"Player Stats/Player Color".color = player.color
	$"Player Stats/Player Name".text = player.tankName
	$"Player Stats/Player Money".text = "($%d)" % player.money
	emit_signal("refresh", player)

func nextPlayer():
	if currentPlayer + 1 >= len(Globals.players):
		tree.change_scene("res://Scenes/Screens/Game.tscn")
	else:
		currentPlayer += 1
		setPlayer(currentPlayer)
