# Multi Reward

Get multiple room rewards in Hades II.

It allows you to receive most room rewards multiple times, such as Boon drop, Weapon enchantment, Health drop, Mana drop, Money drop, Boss rewards, and so on.

By default, the reward count is set to 3.

You can also set the reward count for each reward type.

## Features

1. Multiple rewards.
2. Remove MaxGods limits.
    Now with every expedition into the night, you can receive the boons of all gods, not the previous limit of four gods.
3. Avoid replacing traits.
    Now you can have multiple boons of the same type simultaneously without worrying about the previous ones being replaced.

## Installation Tutorial

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

## Mod Loader

Suggest using [Hell2Modding].

## Requirements

Mod loader:
[Hell2Modding-Hell2Modding-1.0.23]

Supporting mods:
[SGG_Modding-DemonDaemon-1.0.1]
[SGG_Modding-ModUtil-3.1.1]
[SGG_Modding-ENVY-1.0.0]
[SGG_Modding-Chalk-1.0.0]
[SGG_Modding-SJSON-1.0.0]
[SGG_Modding-ReLoad-1.0.1]

## How to configure

You need to modify this configuration file:
`Hades II\Ship\ReturnOfModding\config\Abevol-MultiReward\config.toml`

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
Debug = true
Enabled = true
AvoidReplacingTraits = true
RemoveMaxGodsLimits = true

[RewardCount]
HermesUpgrade = 3
MaxHealthDrop = 3
MaxManaDrop = 3
MemPointsCommonDrop = 3
MetaCurrencyDrop = 3
MixerNBossDrop = 3
MixerOBossDrop = 3
RoomMoneyDrop = 3
Shop = 1
SpellDrop = 1
StackUpgrade = 3
Story = 1
WeaponUpgrade = 3
Others = 3

[RewardCount.Boon]
AphroditeUpgrade = 3
DemeterUpgrade = 3
HephaestusUpgrade = 3
Others = 3
```

[Hell2Modding]: https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/
[Hell2Modding-Hell2Modding-1.0.23]: https://thunderstore.io/package/download/Hell2Modding/Hell2Modding/1.0.23/
[SGG_Modding-DemonDaemon-1.0.1]: https://thunderstore.io/package/download/SGG_Modding/DemonDaemon/1.0.1/
[SGG_Modding-ModUtil-3.1.1]: https://thunderstore.io/package/download/SGG_Modding/ModUtil/3.1.1/
[SGG_Modding-ENVY-1.0.0]: https://thunderstore.io/package/download/SGG_Modding/ENVY/1.0.0/
[SGG_Modding-Chalk-1.0.0]: https://thunderstore.io/package/download/SGG_Modding/Chalk/1.0.0/
[SGG_Modding-SJSON-1.0.0]: https://thunderstore.io/package/download/SGG_Modding/SJSON/1.0.0/
[SGG_Modding-ReLoad-1.0.1]: https://thunderstore.io/package/download/SGG_Modding/ReLoad/1.0.1/
