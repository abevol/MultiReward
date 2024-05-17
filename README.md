# Room Reward Multiplier

Get multiple room rewards in Hades II.

By default, the reward count is set to 3 (based on the value of the "Others" key).

You can also set the reward count for each reward type.

## Mod Loader

Suggest using Hell2Modding.

## Config

```lua
local config = {
    Enabled = true,
    Debug = true,
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
