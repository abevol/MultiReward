# Multi Reward

*"The gods will not be stingy with their rewards, but be careful, lest this invites the calamities of Pandora's box." -- the Nameless One*

Get multiple room rewards in Hades II.

It allows you to receive most room rewards multiple times, such as Boon drop, Weapon enchantment, Health drop, Mana drop, Money drop, Boss rewards, and so on.

By default, the reward count is set to 3.

You can also set the reward count for each reward type.

## Features

1. Multiple rewards.
2. Remove MaxGods limits.
    Now with every expedition into the night, you can receive the boons of all gods, not the previous limit of four gods.
3. Avoid replacing traits.
    Now you can have multiple boons of the same slot simultaneously without worrying about the previous ones being replaced.

## Automatic Installation

Use the [internal-build-of-r2modman].

## Manual Installation

1. Install the mod loader.
Place the main Hell2Modding file, called d3d12.dll, next to the game executable called Hades2.exe inside the game folder.

2. Then run the game.
The mod loader will automatically create the mod file directory in the game directory: Hades II\Ship\ReturnOfModding\plugins.
If you find that this directory has already been generated, you can exit the game to proceed to the next step.

3. Install this mod and supporting mods.
After downloading and extracting the mod, copy it to the above-generated directory: Hades II\Ship\ReturnOfModding\plugins, ensuring the following file path structure (using the manifest.json file as an example):
`Hades II\Ship\ReturnOfModding\plugins\Abevol-MultiReward\manifest.json`
`Hades II\Ship\ReturnOfModding\plugins\SGG_Modding-DemonDaemon\manifest.json`
And so on, the same applies to other mods.
*Note, the structure for the mod folder name must be: 'author-modname'. Do not add version numbers or any extra characters; otherwise, it will result in an error.*

4. Now you can launch the game again, and if there are no surprises, all the mods should start to work.

## Requirements

Mod loader:
[Hell2Modding-Hell2Modding]

Dependencies:
[SGG_Modding-DemonDaemon]
[SGG_Modding-ModUtil]
[SGG_Modding-ENVY]
[SGG_Modding-Chalk]
[SGG_Modding-SJSON]
[SGG_Modding-ReLoad]

## How to configure

You need to modify this configuration file:
`Hades II\Ship\ReturnOfModding\config\Abevol-MultiReward.cfg`

If you encounter a droppable item in the game that you wish to modify, you can immediately see their names highlighted in green in the console log, like this:
`[MultiReward] RewardCount: 1, RewardType: SpellDrop, LootName: nil`
The 'SpellDrop' is the name of the first drop of 'Selene Boons'.

If you want to modify a subtype, for example:
`[MultiReward] RewardCount: 1, RewardType: Boon, LootName: AphroditeUpgrade`
Then you can configure it like this:
`[RewardCount.Boon]`
`AphroditeUpgrade = 3`
`Others = 1`

*Note that 'Others' is a special variable name, which does not correspond to any actual drop in the game. It is solely used by mods to denote 'default values'.*

## Config Example

```ini
Enabled = true
Debug = true
RemoveMaxGodsLimits = true
AvoidReplacingTraits = true
LowerShopPrices = true
UpgradesOptional = true

[RewardCount]
SpellDrop = 1
ClockworkGoal = 1
TalentDrop = 2
StackUpgrade = 3
WeaponUpgrade = 3
HermesUpgrade = 3
GiftDrop = 3
MetaCurrencyDrop = 3
MemPointsCommonDrop = 3
MetaCardPointsCommonDrop = 3
MetaCardPointsCommonBigDrop = 3
RoomMoneyDrop = 3
RoomMoneyTinyDrop = 3
MaxHealthDrop = 3
MaxHealthDropSmall = 3
MaxManaDrop = 3
MaxManaDropSmall = 3
MixerFBossDrop = 3
MixerGBossDrop = 3
MixerHBossDrop = 3
MixerIBossDrop = 3
MixerNBossDrop = 3
MixerOBossDrop = 3
Others = 3

[RewardCount.Story]
Arachne = 3
Narcissus = 3
Echo = 3
Others = 3

[RewardCount.Shop]
DiscountPercent = 67
AphroditeUpgrade = 3
DemeterUpgrade = 3
HephaestusUpgrade = 3
SpellDrop = 1
WeaponUpgradeDrop = 3
ShopHermesUpgrade = 3
ShopManaUpgrade = 3
MaxHealthDrop = 3
MaxHealthDropBig = 3
StackUpgrade = 3
StoreRewardRandomStack = 3
RoomRewardHealDrop = 3
HealBigDrop = 3
ArmorBoost = 3
MemPointsCommonDrop = 3
MetaCardPointsCommonDrop = 3
CardUpgradePointsDrop = 3
WeaponPointsRareDrop = 3
Boon = 3
Consumable = 3
Others = 3

[RewardCount.Boon]
HephaestusUpgrade = 3
AphroditeUpgrade = 3
DemeterUpgrade = 3
Others = 3
```

[internal-build-of-r2modman]: https://github.com/xiaoxiao921/r2modmanPlus/releases/
[Hell2Modding-Hell2Modding]: https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/
[SGG_Modding-DemonDaemon]: https://thunderstore.io/c/hades-ii/p/SGG_Modding/DemonDaemon/
[SGG_Modding-ModUtil]: https://thunderstore.io/c/hades-ii/p/SGG_Modding/ModUtil/
[SGG_Modding-ENVY]: https://thunderstore.io/c/hades-ii/p/SGG_Modding/ENVY/
[SGG_Modding-Chalk]: https://thunderstore.io/c/hades-ii/p/SGG_Modding/Chalk/
[SGG_Modding-SJSON]: https://thunderstore.io/c/hades-ii/p/SGG_Modding/SJSON/
[SGG_Modding-ReLoad]: https://thunderstore.io/c/hades-ii/p/SGG_Modding/ReLoad/
