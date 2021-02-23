extends HBoxContainer

var player

signal itemPurchased

func loadProperties(name, type, price):
	$Name.text = name
	$Type.text = type
	$Price.text = "$%d" % price

# warning-ignore:shadowed_variable
func updateAmt(player):
	self.player = player
	if player.isCC:
		$Owned.text = "-"
	else:
		$Owned.text = "%d" % player.getAmountOwned($Name.text, $Type.text)


func buyItem():
	if player.isCC:
		return
	player.purchaseItem($Name.text, $Type.text, int($Price.text))
	$Owned.text = "%d" % player.getAmountOwned($Name.text, $Type.text)
	emit_signal("itemPurchased")
