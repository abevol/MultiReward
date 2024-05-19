# Room Reward Multiplier

Get multiple room rewards in Hades II.

It allows you to receive most room rewards multiple times, such as Boon drop, Weapon enchantment, Health drop, Mana drop, Money drop, Boss rewards, and so on.

By default, the reward count is set to 3 (based on the value of the "Others" key).

You can also set the reward count for each reward type.

## Features

1. Multiple rewards.
2. Remove MaxGods limits.
    Now with every expedition into the night, you can receive the boons of all gods, not the previous limit of four gods.
3. Avoid replacing traits.
    Now you can have multiple boons of the same type simultaneously without worrying about the previous ones being replaced.

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

4. Now you can launch the game again, and if there are no surprises, all the mods should start to work.

## Config

```lua
local config = {
    Enabled = true,
    Debug = true,
    RemoveMaxGodsLimits = true,
    AvoidReplacingTraits = true,
    RewardCount = {
        -- Set the reward count for each 'RewardType'.
        Story = 1,
        Shop = 1,
        SpellDrop = 1,
        StackUpgrade = 3,
        WeaponUpgrade = 3,
        HermesUpgrade = 3,
        Boon = {
            -- These subkeys are 'LootName'.
            HephaestusUpgrade = 3,
            AphroditeUpgrade = 3,
            DemeterUpgrade = 3,
            Others = 3
        },
        MetaCurrencyDrop = 3,
        MemPointsCommonDrop = 3,
        RoomMoneyDrop = 3,
        MaxHealthDrop = 3,
        MaxManaDrop = 3,
        MixerNBossDrop = 3,
        MixerOBossDrop = 3,
        Others = 3
    }
}
```

[Hell2Modding]: https://thunderstore.io/c/hades-ii/p/Hell2Modding/Hell2Modding/
[Hell2Modding-Hell2Modding-1.0.23]: https://thunderstore.io/package/download/Hell2Modding/Hell2Modding/1.0.23/
[SGG_Modding-DemonDaemon-1.0.1]: https://thunderstore.io/package/download/SGG_Modding/DemonDaemon/1.0.1/
[SGG_Modding-ModUtil-3.1.1]: https://thunderstore.io/package/download/SGG_Modding/ModUtil/3.1.1/
[SGG_Modding-ENVY-1.0.0]: https://thunderstore.io/package/download/SGG_Modding/ENVY/1.0.0/
[SGG_Modding-Chalk-1.0.0]: https://thunderstore.io/package/download/SGG_Modding/Chalk/1.0.0/
[SGG_Modding-SJSON-1.0.0]: https://thunderstore.io/package/download/SGG_Modding/SJSON/1.0.0/
[SGG_Modding-ReLoad-1.0.1]: https://thunderstore.io/package/download/SGG_Modding/ReLoad/1.0.1/
