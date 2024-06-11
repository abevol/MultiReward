local config = {
    Enabled = true,
    Debug = false,
    RemoveMaxGodsLimits = true,
    AvoidReplacingTraits = true, -- Allows multiple traits on one slot
    LowerShopPrices = true, -- Adds a shop discount
    UpgradesOptional = true, -- lets you leave the room without picking up all rewards
    ShopDiscountPercent = 67,
    RewardCount = {
        -- Set the reward count for each 'RewardType'.
        SpellDrop = 1, -- greater than 1 grants more Hex.
        ClockworkGoal = 1, -- when greater than 1, levels will be skipped in the express route.
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
        Story = {
            Arachne = 2,
            Narcissus = 2,
            Echo = 2,
            Others = 5,
        },
        Devotion = 3,
        GiftDrop = 3,
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
    },
    ShopItemCount = {
        Boon = {
            RandomLoot = 3,
            Others = 3
        },
        Consumable = {
            ArmorBoost = 3,
            BlindBoxLoot = 3,
            MaxHealthDrop = 3,
            MaxHealthDropBig = 3,
            MaxManaDrop = 3,
            HealBigDrop = 3,
            RoomRewardHealDrop = 3,
            StackUpgrade = 3,
            ShopHermesUpgrade = 3,
            StoreRewardRandomStack = 3,
            CardUpgradePointsDrop = 3,
            MetaCardPointsCommonDrop = 3,
            Others = 3
        },
        Others = 3
    }
}

local description = {
    Enabled = "Set to true to enable the mod, set to false to disable it.\n设置为true以启用此模组，设置为false以禁用此模组。",
    Debug = "When the mod modifies game data, display a clear text notification within the game.\n当该模组修改游戏数据时，在游戏内显示明文提醒。",
    RemoveMaxGodsLimits = "Now with every expedition into the night, you can receive the boons of all gods, not the previous limit of four gods.\n现在每次深入夜晚的探险，你都可以接受所有神明的恩惠，而不是之前的四位神明的限制。",
    AvoidReplacingTraits = "Now you can have multiple boons of the same slot simultaneously without worrying about the previous ones being replaced.\n现在你可以同时拥有多个相同槽位的恩惠，而不用担心之前的恩惠会被替换掉。",
    LowerShopPrices = "Reduce the price of items in the shop.\n使商店物品的价格降低。",
    ShopDiscountPercent = "Shop discount percentage.\n商店折扣百分比。",
    RewardCount = {
        -- Set the reward count for each 'RewardType'.
        Story = "No effect\n无效",
        Shop = "No effect. Please use the configuration items in 'ShopItemCount' to change the count of items in the shop.\n无效，请使用 ShopItemCount 中的配置项来修改商店物品的数量。",
        SpellDrop = "Greater than 1 grants more Hex.\n大于1时将获得更多咒术。",
        ClockworkGoal = "When greater than 1, levels will be skipped in the express route.\n当大于1时，将在快速通道中跳过若干关卡。",
        TalentDrop = "Keep the setting moderate; too many talent points may prevent closing the talent upgrade interface.\n保持设置适中；太多的天赋点数可能会导致天赋升级界面无法关闭。",
        StackUpgrade = "This is the Pom rewards count.\n这是力量石榴的奖励数量。",
        WeaponUpgrade = "",
        HermesUpgrade = "",
        Boon = {
            -- These subkeys are 'LootName'.
            HephaestusUpgrade = "",
            AphroditeUpgrade = "",
            DemeterUpgrade = "",
            Others = ""
        },
        Devotion = "",
        GiftDrop = "",
        MetaCurrencyDrop = "",
        MemPointsCommonDrop = "",
        MetaCardPointsCommonDrop = "",
        MetaCardPointsCommonBigDrop = "",
        RoomMoneyDrop = "",
        RoomMoneyTinyDrop = "",
        MaxHealthDrop = "",
        MaxHealthDropSmall = "",
        MaxManaDrop = "",
        MaxManaDropSmall = "",
        MixerFBossDrop = "",
        MixerGBossDrop = "",
        MixerHBossDrop = "",
        MixerIBossDrop = "",
        MixerNBossDrop = "",
        MixerOBossDrop = "",
        Others = "The 'Others' is a special key, which does not correspond to any actual drop in the game. It is solely used by mods to denote 'default values'.\n“Others”是一个特殊键，它在游戏中不对应任何实际掉落物。它仅被模组用来表示“默认值”。"
    },
    ShopItemCount = {
        Boon = {
            RandomLoot = "",
            Others = ""
        },
        Consumable = {
            ArmorBoost = "",
            BlindBoxLoot = "",
            MaxHealthDrop = "",
            MaxHealthDropBig = "",
            MaxManaDrop = "",
            HealBigDrop = "",
            RoomRewardHealDrop = "",
            StackUpgrade = "",
            ShopHermesUpgrade = "",
            StoreRewardRandomStack = "",
            CardUpgradePointsDrop = "",
            MetaCardPointsCommonDrop = "",
            Others = ""
        },
        Others = ""
    }
}

return config, description