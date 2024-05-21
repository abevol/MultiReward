return {
    Enabled = true,
    Debug = true,
    RemoveMaxGodsLimits = true,
    AvoidReplacingTraits = true,
    RewardCount = {
        -- Set the reward count for each 'RewardType'.
        Story = 1, -- no effect
        Shop = 1, -- no effect
        SpellDrop = 1, -- greater than 1 grants more Hex.
        TalentDrop = 2, -- keep the setting moderate; too many talent points may prevent closing the talent upgrade interface.
        StackUpgrade = 3, -- this is the Pom rewards count.
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
        Others = 3 -- the 'Others' is a special key, which does not correspond to any actual drop in the game. It is solely used by mods to denote 'default values'.
    }
}