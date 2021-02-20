# Tanks

Godot rewrite of [Tanks](https://github.com/Arc676/Tanks). Based on [this UBports build of Circle Jump](https://gitlab.com/abmyii/ubports-circle-jump) by abmyii.

Tanks is an online flash game originally hosted on 2dplay.com. It does not appear to be hosted there anymore. Simply searching for "Tanks flash game" will give many results. This is a game based on that game but is not affiliated with the original in any way.

### Gameplay
Between 2 and 4 players (any number of which can be computer controlled) control tanks of any color and must destroy all opponents. Successful attacks on other players increase your score and earn money that can be used to purchase better ammunition and tank upgrades. If a tank is destroyed instead of merely damaged, the rewards are doubled.

Players can be assigned to teams; the game then ends when only one team remains. Friendly fire earns no money and decreases your score instead of increasing it.

A tank's HP level indicates how much more damage it can take before being destroyed. This information only becomes visible on that tank's turn.

Tank firepower controls the initial speed of fired projectiles and thus the distance they will travel. Use this and the firing angle to hit your opponents.

The wind will affect your projectiles' trajectories. Keep a close eye on the wind bar to see which way it's blowing and with what strength. The movement of the clouds provides this same information.

If the game doesn't look like it's going to end any time soon, you can click "Draw Game" to declare a draw. All remaining players receive points and money and the game ends.

### Store

In the store, you can buy new weapons, upgrades, items, and alter tank properties. The table shows information about the different purchasable items and how many you own. Select a row and press enter or click "purchase selected item" to purchase the item.

From the store view, you can also save tanks to disk so you can use them again in another session.

### Items

Items appear in the control bar. Click on them to activate or use them.

Shields: A shield can absorb a limited amount of damage before being depleted. Absorbed damage is not dealt to your tank armor. Excess damage past the shield's threshold *is* dealt to your tank armor. Use this to buy yourself a few more turns if you're taking many hits. Once activated, your shield will persist across rounds until it is completely depleted. If you save your tank data to disk, it will also persist across sessions. You cannot activate multiple shields simultaneously.

Repair kits: Restores a limited amount of HP. Also buys more turns if you've taken a lot of damage. Single use.

Teleport: Teleports you to a chosen location on the map. Note that teleporting ends your turn. You may not teleport to another location and fire on another tank from that location in the same turn. During your turn, you may either teleport or fire, but not both. Single use.

### Upgrades

Upgrades are permanent enhancements to your tank's properties. You can purchase upgrades for engine (fuel) efficiency, armor, the ability to climb steeper hills, and starting each round with more fuel.

### Controls
- Up/Down to turn cannon CW/CCW
- Left/Right to move tank (you have a limited amount of fuel per round)
- Space to fire. If you are using a targeted weapon, such as an air strike, click on the target location to fire. Press ESC to cancel. Keep in mind that the wind still affects targeted weapons.
- PgUp/PgDn to increase/decrease firepower (Fn+Up/Fn+Down if you don't have an extended keyboard)
- Q/W to switch to your next/previous weapon

### Other features
- Saving tank data to disk between sessions and restoring them for the next game
- Different strategies and combat styles for computer controlled tanks
- Tanks can activate shields that persist across matches (the shield level also persists)

### Legal
Project available under GPLv3. See `CREDITS` for details regarding assets and `LICENSE` for full GPL text.
