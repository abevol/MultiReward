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
        GiftDrop = 3,
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

MultiReward.Config = config
return config