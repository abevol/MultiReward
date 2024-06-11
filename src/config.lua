return {
    Enabled = true,
    Debug = true,
    RemoveMaxGodsLimits = true,
    AvoidReplacingTraits = true, -- Allows multiple traits on one slot
    LowerShopPrices = true, -- Adds a shop discount
    UpgradesOptional = true, -- lets you leave the room without picking up all rewards
    RewardCount = {
        -- Set the reward count for each 'RewardType'.
        SpellDrop = 1, -- greater than 1 grants more Hex.
        ClockworkGoal = 1, -- when greater than 1, levels will be skipped in the express route.
        TalentDrop = 2, -- keep the setting moderate; too many talent points may prevent closing the talent upgrade interface.
        StackUpgrade = 3, -- this is the Pom rewards count.
        WeaponUpgrade = 3,
        HermesUpgrade = 3,
        Story = {
            Arachne = 3,
            Narcissus = 3,
            Echo = 3,
            Others = 3,
        },
        Shop = {
            DiscountPercent = 67, -- Shop prices are lowered by this amount
            AphroditeUpgrade = 3,
            DemeterUpgrade = 3,
            HephaestusUpgrade = 3,
            SpellDrop = 1,
            WeaponUpgradeDrop = 3,
            ShopHermesUpgrade = 3,
            ShopManaUpgrade = 3,
            MaxHealthDrop = 3,
            MaxHealthDropBig = 3,
            StackUpgrade = 3,
            StoreRewardRandomStack = 3, -- sliced pom
            RoomRewardHealDrop = 3,
            HealBigDrop = 3,
            ArmorBoost = 3,
            MemPointsCommonDrop = 3,
            MetaCardPointsCommonDrop = 3,
            CardUpgradePointsDrop = 3, -- moondust
            WeaponPointsRareDrop = 3, -- nightmare
            Boon = 3,
            Consumable = 3,
            Others = 3
        },
        Boon = {
            -- These subkeys are 'LootName'.
            HephaestusUpgrade = 3,
            AphroditeUpgrade = 3,
            DemeterUpgrade = 3,
            Others = 3
        },
        GiftDrop = 3, -- Nectar
        MetaCurrencyDrop = 3,
        MemPointsCommonDrop = 3, -- Psyche
        MetaCardPointsCommonDrop = 3, -- Ashes
        MetaCardPointsCommonBigDrop = 3,
        RoomMoneyDrop = 3,
        RoomMoneyTinyDrop = 3,
        MaxHealthDrop = 3,
        MaxHealthDropSmall = 3,
        MaxManaDrop = 3,
        MaxManaDropSmall = 3,
        MixerFBossDrop = 3, -- Hecate Metacurrency
        MixerGBossDrop = 3, -- Scylla Metacurrency
        MixerHBossDrop = 3, -- Cerberus Metacurrency
        MixerIBossDrop = 3, -- Chronos Metacurrency
        MixerNBossDrop = 3, -- Polyphemus Metacurrency
        MixerOBossDrop = 3, -- Eris Metacurrency
        Others = 3 -- the 'Others' is a special key, which does not correspond to any actual drop in the game. It is solely used by mods to denote 'default values'.
    }
}