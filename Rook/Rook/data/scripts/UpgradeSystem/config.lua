ITEM_UPGRADE_CRYSTAL = 1
ITEM_ENCHANT_CRYSTAL = 2
ITEM_ALTER_CRYSTAL = 3
ITEM_CLEAN_CRYSTAL = 4
ITEM_FORTUNE_CRYSTAL = 5
ITEM_FAITH_CRYSTAL = 6

COMMON = 1
RARE = 2
EPIC = 3
LEGENDARY = 4


US_CONFIG = {
  {
    -- crystals here can be extracted using Crystal Extractor
    [ITEM_UPGRADE_CRYSTAL] = 7870, -- Upgrade Crystal item id
    [ITEM_ENCHANT_CRYSTAL] = 7871, -- Enchantment Crystal item id
    [ITEM_ALTER_CRYSTAL] = 7872, -- Alteration Crystal item id
    [ITEM_CLEAN_CRYSTAL] = 7873, -- Cleansing Crystal item id
    [ITEM_FORTUNE_CRYSTAL] = 7874, -- Fortune Crystal item id
    [ITEM_FAITH_CRYSTAL] = 7875, -- Faith Crystal item id
  },
ITEM_MIND_CRYSTAL = 7876, -- Mind Crystal item id
  ITEM_LIMITLESS_CRYSTAL = 7877, -- Limitless Crystal item id
  ITEM_MIRRORED_CRYSTAL = 7878, -- Mirrored Crystal item id
  ITEM_VOID_CRYSTAL = 7879, -- Void Crystal item id
  ITEM_RARITY_CRYSTAL = 7893, -- Rarity Crystal item id (+1 rarity level)
  ITEM_TIER_CRYSTAL = 7894, -- Tier Crystal item id (+1 tier level)
  ITEM_SCROLL_IDENTIFY = 7953, -- Scroll of Identification item id
  ITEM_UPGRADE_CATALYST = 7881, -- Upgrade Catalyst item id
  CRYSTAL_EXTRACTOR = 7882, -- Crystal Extractor item id
  CRYSTAL_FOSSIL = 7883, -- Crystal Fossil item id
  --
  IDENTIFY_UPGRADE_LEVEL = false, -- if true, roll random upgrade level when identifing an item
  UPGRADE_SUCCESS_CHANCE = {[1] = 100, [2] = 100, [3] = 95, [4] = 80, [5] = 65, [6] = 40}, -- % chance for the upgrade at given upgrade level, -1 upgrade level on failure
  UPGRADE_LEVEL_DESTROY = 7, -- at which upgrade level should it break if failed, for example if = 7 then upgrading from +6 to +7-9 can destroy item on failure.
  UPGRADE_DESTROY_CHANCE = {[7] = 30, [8] = 15, [9] = 5}, -- chance for the item to break at given upgrade level
  --
  MAX_ITEM_LEVEL = 3000, -- max that Item Level can be assigned to item
  MAX_UPGRADE_LEVEL = 9, -- fallback max level that item can be upgraded to when item has no tier
  MAX_UPGRADE_LEVEL_PER_TIER = 3, -- if > 0 then max upgrade = item tier * value
  --
  USE_ITEM_XML_TIERS = true, -- when true, use <attribute key="tier" value="X"/> from items.xml
  ITEM_TIER_MIN = 1, -- minimum supported tier
  ITEM_TIER_MAX = 25, -- maximum supported tier
  ITEM_LEVEL_PER_TIER = 25, -- tier N max level = N * ITEM_LEVEL_PER_TIER
  ITEM_LEVEL_FIRST_TIER_MIN = 1, -- tier 1 min level (tier 2 starts at previous max)
  -- Optional legacy override per tier:
  -- ITEM_LEVEL_TIERS = { [1]={min=1,max=25}, [2]={min=25,max=50}, ... }
  --
  ATTACK_PER_ITEM_LEVEL = 15, -- every X effective Item Level +ATTACK_FROM_ITEM_LEVEL attack
  ATTACK_FROM_ITEM_LEVEL = 1, -- +X bonus attack for every ATTACK_PER_ITEM_LEVEL
  DEFENSE_PER_ITEM_LEVEL = 15, -- every X effective Item Level +DEFENSE_FROM_ITEM_LEVEL defense
  DEFENSE_FROM_ITEM_LEVEL = 1, -- +X bonus defense for every DEFENSE_PER_ITEM_LEVEL
  ARMOR_PER_ITEM_LEVEL = 15, -- every X effective Item Level +ARMOR_FROM_ITEM_LEVEL armor
  ARMOR_FROM_ITEM_LEVEL = 1, -- +X bonus armor for every ARMOR_PER_ITEM_LEVEL
  HITCHANCE_PER_ITEM_LEVEL = 15, -- every X effective Item Level +HITCHANCE_FROM_ITEM_LEVEL hit chance
  HITCHANCE_FROM_ITEM_LEVEL = 1, -- +X bonus hit chance for every HITCHANCE_PER_ITEM_LEVEL
  -- Effective Item Level for stat scaling starts above current tier max (e.g. T25 max=625, first bonus at 640).
  ITEM_LEVEL_STAT_TIER_BASE = true,
  --
  UPGRADE_ITEM_LEVEL_BY_RARITY = {
    [COMMON] = 1,
    [RARE] = 2,
    [EPIC] = 5,
    [LEGENDARY] = 10
  },
  --
  ITEM_LEVEL_PER_ATTACK = 1, -- +1 to Item Level for every X Attack in item
  ITEM_LEVEL_PER_DEFENSE = 1, -- +1 to Item Level for every X Defense in item
  ITEM_LEVEL_PER_ARMOR = 1, -- +1 to Item Level for every X Armor in item
  ITEM_LEVEL_PER_HITCHANCE = 1, -- +1 to Item Level for every X Hit Chance in item
  ITEM_LEVEL_PER_UPGRADE = 1, -- additional item level per upgrade level
  --
  ATTACK_PER_UPGRADE = 1, -- amount of bonus attack per upgrade level
  DEFENSE_PER_UPGRADE = 1, -- amount of bonus defense per upgrade level
  EXTRADEFENSE_PER_UPGRADE = 1, -- amount of bonus extra defense per upgrade level
  ARMOR_PER_UPGRADE = 1, -- amount of bonus armor per upgrade level
  HITCHANCE_PER_UPGRADE = 1, -- amount of bonus hit chance per upgrade level
  --
  CRYSTAL_FOSSIL_DROP_CHANCE = 8, -- 1:X chance that Crystal Fossil will drop from monster, X means that approximately every X monster will drop Crystal Fossil
  CRYSTAL_FOSSIL_DROP_LEVEL = 2500, -- X monster level needed to drop Crystal Fossil
  UNIDENTIFIED_DROP_CHANCE = 12, -- 1:X chance that item in monster corpse will be unidentified
  CRYSTAL_BREAK_CHANCE = 5, -- 1:X chance that Crystal will break when extracted from Fossil, X means that approximately every X Crystal will break
  UNIQUE_CHANCE = 4000, -- 1:X chance that unidentified item will become Unique
  REQUIRE_LEVEL = false, -- block equipping items with higher Item Level than Player Level
  RARITY_ROLL_SCALE = 1000,
  RARITY_NO_BONUS_COMMON_CUTOFF = 50, -- 5% of 1000 rolls keep common and skip bonus slots
  -- Drop roll: common 98.5%, rare 1.0%, epic 0.4%, legendary 0.1%
  RARITY_DROP_CHANCE = {
    [COMMON] = 1,
    [RARE] = 986,
    [EPIC] = 996,
    [LEGENDARY] = 1000
  },
  -- Identify roll (unidentified items): common 85%, rare 10%, epic 4%, legendary 1%
  RARITY_IDENTIFY_CHANCE = {
    [COMMON] = 1,
    [RARE] = 851,
    [EPIC] = 951,
    [LEGENDARY] = 991
  },
  RARITY_ITEM_LEVEL_MULTIPLIER = {
    [COMMON] = 1.0,
    [RARE] = 1.5,
    [EPIC] = 2.0,
    [LEGENDARY] = 3.0
  },
  -- Bonus value scaling:
  -- If BONUS_VALUE_TICK_EVERY_DEFAULT > 0 then bonus value uses:
  -- value = 1 + floor((itemLevel - baseLevel) / tick)
  -- baseLevel = max(minLevel, BASE_ITEM_LEVEL, BONUS_BASE_ITEM_LEVEL_DEFAULT)
  -- Per enchant override keys:
  --   BASE_ITEM_LEVEL = X
  --   VALUE_TICK_EVERY = Y
  BONUS_BASE_ITEM_LEVEL_DEFAULT = 1,
  BONUS_VALUE_TICK_EVERY_DEFAULT = 15,
  RARITY = {
    [COMMON] = {
      name = "common",
      maxBonus = 1, -- max amount of bonus attributes
      chance = 1 -- fallback threshold
    },
    [RARE] = {
      name = "rare",
      maxBonus = 2, -- max amount of bonus attributes
      chance = 851 -- fallback threshold (identify profile)
    },
    [EPIC] = {
      name = "epic",
      maxBonus = 3, -- max amount of bonus attributes
      chance = 951 -- fallback threshold (identify profile)
    },
    [LEGENDARY] = {
      name = "legendary",
      maxBonus = 4, -- max amount of bonus attributes
      chance = 991 -- fallback threshold (identify profile)
    }
  }
}

US_ITEM_TYPES = {
  ALL = 1,
  WEAPON_MELEE = 2,
  WEAPON_DISTANCE = 4,
  WEAPON_WAND = 8,
  SHIELD = 16,
  HELMET = 32,
  ARMOR = 64,
  LEGS = 128,
  BOOTS = 256,
  RING = 512,
  NECKLACE = 1024,
  WEAPON_ANY = 14
}

US_UNIQUES = {
  [1] = {
    name = "Flame Spirit",
    attributes = {
      1, -- Max HP
      4, -- Melee Skills
      12, -- Life Steal
      30 -- Flame Strike on Attack
    },
    minLevel = 35, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.WEAPON_MELEE -- Can be rolled only for items like Swords, Axes and Clubs
  },
  [2] = {
    name = "Ice Spirit",
    attributes = {
      2, -- Max MP
      3, -- Magic Level
      32, -- Ice Strike on Attack
      44 -- Regenerate Mana on Kill
    },
    minLevel = 70, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.WEAPON_WAND + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE -- Can be rolled only for items like Wands, Rods, Rings, Necklaces
  },
  [3] = {
    name = "Terra Spirit",
    attributes = {
      1, -- Max HP
      2, -- Max MP
      3, -- Magic Level
      34 -- Terra Strike on Attack
    },
    minLevel = 70, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.WEAPON_WAND + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE -- Can be rolled only for items like Wands, Rods, Rings, Necklaces
  },
  [4] = {
    name = "Blessed",
    attributes = {
      22, -- physical protection
	 29, -- elemental protection
	 49, -- increased healing
	 13 -- experience
    },
    minLevel = 45, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.SHIELD -- Can be rolled only for items like Wands, Rods, Rings, Necklaces
  },
  [5] = {
    name = "Plunderer",
    attributes = {
       2, -- Max MP
      3, -- Magic Level
      50, -- extra gold
	 13 -- experience
    },
    minLevel = 30, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE -- Can be rolled only for items like Wands, Rods, Rings, Necklaces
  },
  [6] = {
    name = "Reinforced",
    attributes = {
      1, -- max hp
	 4, -- melee skills
	 14, -- physical damage
	 51 -- double
    },
    minLevel = 35, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.WEAPON_MELEE -- Can be rolled only for items like Swords, Axes and Clubs
  },
  [7] = {
    name = "Weaponized",
    attributes = {
	 9, -- distance
	 14, --phys+
	 43, --hp++
	 49 -- healing
    },
    minLevel = 35, -- Required Item Level to become Unique
    chance = 80, -- % chance to roll this unique
    itemType = US_ITEM_TYPES.WEAPON_DISTANCE -- Can be rolled only for items like Swords, Axes and Clubs
  }
  
}

US_TYPES = {
  CONDITION = 0,
  OFFENSIVE = 1,
  DEFENSIVE = 2,
  TRIGGER = 3
}

US_TRIGGERS = {
  ATTACK = 0,
  HIT = 1,
  KILL = 2
}

US_ENCHANTMENTS = {
  [1] = {
    name = "Max HP",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_STAT_MAXHITPOINTS,
    VALUES_PER_LEVEL = 1,
    format = function(value)
      return "Max HP +" .. value
    end,
    itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [2] = {
    name = "Max MP",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_STAT_MAXMANAPOINTS,
    VALUES_PER_LEVEL = 1,
    format = function(value)
      return "Max MP +" .. value
    end,
    itemType = US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [3] = {
    name = "Magic Level",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_STAT_MAGICPOINTS,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Magic Level +" .. value
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [4] = {
    name = "Melee Skills",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_MELEE,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Melee Skills +" .. value
    end,
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [5] = {
    name = "Fist Fighting",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_FIST,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Fist Fightning +" .. value
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 30
  },
  [6] = {
    name = "Sword Fighting",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_SWORD,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Sword Fighting +" .. value
    end,
    itemType = US_ITEM_TYPES.WEAPON_MELEE + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.BOOTS,
    allowedWeaponTypes = {WEAPON_SWORD}
  },
  [7] = {
    name = "Axe Fighting",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_AXE,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Axe Fighting +" .. value
    end,
    itemType = US_ITEM_TYPES.WEAPON_MELEE + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
    allowedWeaponTypes = {WEAPON_AXE}
  },
  [8] = {
    name = "Club Fighting",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_CLUB,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Club Fighting +" .. value
    end,
    itemType = US_ITEM_TYPES.WEAPON_MELEE + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
    allowedWeaponTypes = {WEAPON_CLUB}
  },
  [9] = {
    name = "Distance Fighting",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_DISTANCE,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Distance Fighting +" .. value
    end,
    itemType = US_ITEM_TYPES.WEAPON_DISTANCE + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
    allowedWeaponTypes = {WEAPON_DISTANCE},
    allowedAmmoTypes = {AMMO_ARROW, AMMO_BOLT}
  },
  [10] = {
    name = "Shielding",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SKILL_SHIELD,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 15,
    VALUES_PER_LEVEL = 0.25,
    format = function(value)
      return "Shielding +" .. value
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [11] = {
    name = "Mana Shield",
    minLevel = 50,
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_MANASHIELD,
    format = function(value)
      return "Mana Shield"
    end,
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [12] = {
    name = "Life Steal",
    combatType = US_TYPES.OFFENSIVE,
    VALUES_PER_LEVEL = 0.1,
    format = function(value)
      return "Heal for " .. value .. "%% of dealt damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_MELEE + US_ITEM_TYPES.WEAPON_DISTANCE,
    chance = 10
  },
  [13] = {
    name = "Experience",
    VALUES_PER_LEVEL = 0.35,
    format = function(value)
      return "Experience +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.BOOTS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    chance = 30
  },
  [14] = {
    name = "Physical Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_PHYSICALDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Physical Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [15] = {
    name = "Energy Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_ENERGYDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Energy Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [16] = {
    name = "Earth Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_EARTHDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Earth Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [17] = {
    name = "Fire Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_FIREDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Fire Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [18] = {
    name = "Ice Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_ICEDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Ice Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [19] = {
    name = "Holy Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_HOLYDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Holy Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [20] = {
    name = "Death Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_DEATHDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Death Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [21] = {
    name = "Elemental Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Elemental Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.RING,
    chance = 50
  },
  [22] = {
    name = "Physical Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_PHYSICALDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Physical Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [23] = {
    name = "Energy Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_ENERGYDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Energy Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [24] = {
    name = "Earth Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_EARTHDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Earth Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [25] = {
    name = "Fire Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_FIREDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Fire Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [26] = {
    name = "Ice Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_ICEDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Ice Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [27] = {
    name = "Holy Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_HOLYDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Holy Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [28] = {
    name = "Death Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_DEATHDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Death Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
	chance = 10
  },
  [29] = {
    name = "Elemental Protection",
    combatType = US_TYPES.DEFENSIVE,
    combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE,
    VALUES_PER_LEVEL = 2,
    format = function(value)
      return "Elemental Protection +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS,
    chance = 10
  },
  [30] = {
    name = "Flame Strike on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.ATTACK,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 5 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_FIRE)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_FIREDAMAGE, 1, damage, CONST_ME_FIREATTACK, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "4%% to cast Flame Strike on Attack dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [31] = {
    name = "Flame Strike on Hit",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 10 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_FIRE)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_FIREDAMAGE, 1, damage, CONST_ME_FIREATTACK, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "9%% to cast Flame Strike on Hit dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [32] = {
    name = "Ice Strike on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.ATTACK,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 5 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SMALLICE)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_ICEDAMAGE, 1, damage, CONST_ME_ICEATTACK, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "4%% to cast Ice Strike on Attack dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [33] = {
    name = "Ice Strike on Hit",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 10 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SMALLICE)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_ICEDAMAGE, 1, damage, CONST_ME_ICEATTACK, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "9%% to cast Ice Strike on Hit dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [34] = {
    name = "Terra Strike on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.ATTACK,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 20 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SMALLEARTH)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_EARTHDAMAGE, 1, damage, CONST_ME_CARNIPHILA, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "19%% to cast Terra Strike on Attack dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [35] = {
    name = "Terra Strike on Hit",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 10 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SMALLEARTH)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_EARTHDAMAGE, 1, damage, CONST_ME_CARNIPHILA, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "9%% to cast Terra Strike on Hit dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [36] = {
    name = "Death Strike on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.ATTACK,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 5 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_DEATH)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_DEATHDAMAGE, 1, damage, CONST_ME_MORTAREA, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "4%% to cast Death Strike on Attack dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [37] = {
    name = "Death Strike on Hit",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 10 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_DEATH)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_DEATHDAMAGE, 1, damage, CONST_ME_MORTAREA, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "9%% to cast Death Strike on Hit dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS
  },
  [38] = {
    name = "Divine Missile on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.ATTACK,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 5 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SMALLHOLY)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_HOLYDAMAGE, 1, damage, CONST_ME_HOLYDAMAGE, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "4%% to cast Divine Missile on Attack dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [39] = {
    name = "Divine Missile on Hit",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 10 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_SMALLHOLY)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_HOLYDAMAGE, 1, damage, CONST_ME_HOLYDAMAGE, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "9%% to cast Divine Missile on Hit dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [40] = {
    name = "Energy Strike on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.ATTACK,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 5 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_ENERGY)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_ENERGYDAMAGE, 1, damage, CONST_ME_ENERGYAREA, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "4%% to cast Energy Strike on Attack dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [41] = {
    name = "Energy Strike on Hit",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.5,
    execute = function(attacker, target, damage)
      if math.random(100) < 10 then
        attacker:getPosition():sendDistanceEffect(target:getPosition(), CONST_ANI_ENERGY)
        doTargetCombatHealth(attacker:getId(), target, COMBAT_ENERGYDAMAGE, 1, damage, CONST_ME_ENERGYAREA, ORIGIN_CONDITION)
      end
    end,
    format = function(value)
      return "9%% to cast Energy Strike on Hit dealing up to " .. value .. " damage"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS
  },
  [42] = {
    name = "Explosion on Kill",
    minLevel = 50,
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    VALUES_PER_LEVEL = 0.5,
    execute = function(player, value, center, target)
      local damage = math.ceil(target:getMaxHealth() * (value / 100))
      exoriEffect(center, CONST_ME_FIREAREA)
      local specs = Game.getSpectators(center, false, false, 1, 1, 1, 1)
      if #specs > 0 then
        for i = 1, #specs do
          if specs[i]:isMonster() then
            doTargetCombatHealth(player:getId(), specs[i]:getId(), COMBAT_FIREDAMAGE, 1, damage, CONST_ME_NONE, ORIGIN_CONDITION)
          end
        end
      end
    end,
    format = function(value)
      return "Explosion on Kill dealing " .. value .. "%% Max HP of a killed monster"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [43] = {
    name = "Health on Kill",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    VALUES_PER_LEVEL = 0.2,
    execute = function(player, value, center, target)
      player:addHealth(value)
    end,
    format = function(value)
      return "Regenerate " .. value .. " Health on Kill"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    chance = 25
  },
  [44] = {
    name = "Mana on Kill",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    VALUES_PER_LEVEL = 0.1,
    execute = function(player, value, center, target)
      player:addMana(value)
    end,
    format = function(value)
      return "Regenerate " .. value .. " Mana on Kill"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    chance = 25
  },
  [45] = {
    name = "Mana Steal",
    combatType = US_TYPES.OFFENSIVE,
    VALUES_PER_LEVEL = 0.1,
    format = function(value)
      return "Regenerate Mana for " .. value .. "%% of dealt damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY,
    chance = 10
  },
  [46] = {
    name = "Full HP on Kill",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    VALUES_PER_LEVEL = 0.05,
    execute = function(player, value, center, target)
      if math.random(100) < value then
        player:addHealth(player:getMaxHealth())
      end
    end,
    format = function(value)
      return value .. "%% to regenerate full HP on Kill"
    end,
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    allowedItemIds = {2471},
    minLevel = 70,
    chance = 5
  },
  [47] = {
    name = "Full MP on Kill",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    VALUES_PER_LEVEL = 0.05,
    execute = function(player, value, center, target)
      if math.random(100) < value then
        player:addMana(player:getMaxMana())
      end
    end,
    format = function(value)
      return value .. "%% to regenerate full MP on Kill"
    end,
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    allowedItemIds = {6480},
    minLevel = 70,
    chance = 5
  },
  [48] = {
    name = "Mass Healing on Attack",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.HIT,
    VALUES_PER_LEVEL = 0.2,
    execute = function(attacker, target, damage)
      if math.random(100) < damage then
        local min = (attacker:getLevel() / 5) + (attacker:getMagicLevel() * 4.6) + 100
        local max = (attacker:getLevel() / 5) + (attacker:getMagicLevel() * 9.6) + 125

        doAreaCombatHealth(target:getId(), COMBAT_HEALING, attacker:getPosition(), 6, min, max, CONST_ME_MAGIC_BLUE)
      end
    end,
    format = function(value)
      return value .. "%% to cast Mass Healing on Attack"
    end,
    itemType = 0,
    allowedItemIds = {7088},
    minLevel = 100,
    chance = 15
  },
  [49] = {
    name = "Increased Healing",
    VALUES_PER_LEVEL = 0.35,
    format = function(value)
      return value .. "%% more healing from all sources"
    end,
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    minLevel = 25,
    chance = 20
  },
  [50] = {
    name = "Additonal Gold",
    VALUES_PER_LEVEL = 0.5,
    format = function(value)
      return value .. "%% more gold from loot [Hoarder]"
    end,
    itemType = US_ITEM_TYPES.ALL,
    minLevel = 10,
    chance = 30
  },
  [51] = {
    name = "Double Damage",
    combatType = US_TYPES.OFFENSIVE,
    combatDamage = COMBAT_ENERGYDAMAGE + COMBAT_EARTHDAMAGE + COMBAT_FIREDAMAGE + COMBAT_ICEDAMAGE + COMBAT_HOLYDAMAGE + COMBAT_DEATHDAMAGE +
      COMBAT_PHYSICALDAMAGE,
    minLevel = 100,
    BASE_ITEM_LEVEL = 100,
    VALUE_TICK_EVERY = 50,
    VALUES_PER_LEVEL = 0.1,
    format = function(value)
      return value .. "%% to deal double damage"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY,
    chance = 5
  },
  [52] = {
    name = "Revive on death",
    VALUES_PER_LEVEL = 0.05,
    format = function(value)
      return value .. "%% to be revived"
    end,
    itemType = US_ITEM_TYPES.BOOTS,
    allowedItemIds = {6480},
    minLevel = 100,
    chance = 30
  },
  [53] = {
    name = "Damage Buff",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 15,
    execute = function(player, value, center, target, sourceItem)
      local itemLevel = 1
      if sourceItem and sourceItem.getItemLevel then
        itemLevel = math.max(1, math.floor(tonumber(sourceItem:getItemLevel()) or 1))
      end

      -- Proc chance scales separately from buff value:
      -- starts at 1% and gains +1% every 60 item levels.
      local procChance = 1 + math.floor((itemLevel - 1) / 60)
      procChance = math.max(1, math.min(100, procChance))

      if math.random(100) <= procChance then
        local pid = player:getId()
        local buffId = 1
        if not US_BUFFS[pid] then
          US_BUFFS[pid] = {}
        end
        if not US_BUFFS[pid][buffId] then
          US_BUFFS[pid][buffId] = {}
          US_BUFFS[pid][buffId].value = value
          player:sendTextMessage(MESSAGE_INFO_DESCR, "Damage Buff applied for 8 seconds!")
          US_BUFFS[pid][buffId].event = addEvent(us_RemoveBuff, 8000, pid, buffId, "Damage Buff")
        else
          stopEvent(US_BUFFS[pid][buffId].event)
          US_BUFFS[pid][buffId].value = value
          player:sendTextMessage(MESSAGE_INFO_DESCR, "Damage Buff reapplied for 8 seconds!")
          US_BUFFS[pid][buffId].event = addEvent(us_RemoveBuff, 8000, pid, buffId, "Damage Buff")
        end
      end
    end,
    format = function(value)
      return "1%% +1%% per 60 Item Level to get " .. value .. "%% damage buff for 8 sec. on Kill"
    end,
    itemType = US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE,
    chance = 10
  },
  [54] = {
    name = "Max HP Buff",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    buff = true,
    VALUES_PER_LEVEL = 0.5,
    execute = function(player, value)
      if math.random(100) < 20 then
        local pid = player:getId()
        local buffId = 2
        if not US_BUFFS[pid] then
          US_BUFFS[pid] = {}
        end
        if not US_BUFFS[pid][buffId] then
          US_BUFFS[pid][buffId] = {}
          US_BUFFS[pid][buffId].condition = Condition(CONDITION_ATTRIBUTES)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_STAT_MAXHITPOINTSPERCENT, 100 + value)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_TICKS, 8000)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_SUBID, 3245)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
          player:addCondition(US_BUFFS[pid][buffId].condition)
          player:sendTextMessage(MESSAGE_INFO_DESCR, "Max HP Buff applied for 8 seconds!")
          US_BUFFS[pid][buffId].event = addEvent(us_RemoveBuff, 8000, pid, buffId, "Max HP Buff")
        else
          stopEvent(US_BUFFS[pid][buffId].event)
          player:sendTextMessage(MESSAGE_INFO_DESCR, "Max HP Buff reapplied for 8 seconds!")
          US_BUFFS[pid][buffId].event = addEvent(us_RemoveBuff, 8000, pid, buffId, "Max HP Buff")
          player:removeCondition(US_BUFFS[pid][buffId].condition)
          player:addCondition(US_BUFFS[pid][buffId].condition)
        end
      end
    end,
    format = function(value)
      return "19%% to get " .. value .. "%% Max HP buff for 8 sec. on Kill"
    end,
    itemType = 0,
    minLevel = 30,
    chance = 10
  },
  [55] = {
    name = "Max MP Buff",
    combatType = US_TYPES.TRIGGER,
    triggerType = US_TRIGGERS.KILL,
    buff = true,
    VALUES_PER_LEVEL = 0.5,
    execute = function(player, value)
      if math.random(100) < 20 then
        local pid = player:getId()
        local buffId = 3
        if not US_BUFFS[pid] then
          US_BUFFS[pid] = {}
        end
        if not US_BUFFS[pid][buffId] then
          US_BUFFS[pid][buffId] = {}
          US_BUFFS[pid][buffId].condition = Condition(CONDITION_ATTRIBUTES)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_STAT_MAXMANAPOINTSPERCENT, 100 + value)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_TICKS, 8000)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_SUBID, 3246)
          US_BUFFS[pid][buffId].condition:setParameter(CONDITION_PARAM_BUFF_SPELL, true)
          player:addCondition(US_BUFFS[pid][buffId].condition)
          player:sendTextMessage(MESSAGE_INFO_DESCR, "Max MP Buff applied for 8 seconds!")
          US_BUFFS[pid][buffId].event = addEvent(us_RemoveBuff, 8000, pid, buffId, "Max MP Buff")
        else
          stopEvent(US_BUFFS[pid][buffId].event)
          player:sendTextMessage(MESSAGE_INFO_DESCR, "Max MP Buff reapplied for 8 seconds!")
          US_BUFFS[pid][buffId].event = addEvent(us_RemoveBuff, 8000, pid, buffId, "Max MP Buff")
          player:removeCondition(US_BUFFS[pid][buffId].condition)
          player:addCondition(US_BUFFS[pid][buffId].condition)
        end
      end
    end,
    format = function(value)
      return "19%% to get " .. value .. "%% Max MP buff for 8 sec. on Kill"
    end,
    itemType = 0,
    minLevel = 30,
    chance = 10
  },
  [56] = {
    name = "Critical Hit Chance",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SPECIALSKILL_CRITICALHITCHANCE,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 30,
    format = function(value)
      return "Critical Hit Chance +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [57] = {
    name = "Critical Hit Damage",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SPECIALSKILL_CRITICALHITAMOUNT,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 30,
    format = function(value)
      return "Critical Hit Damage +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY + US_ITEM_TYPES.RING + US_ITEM_TYPES.NECKLACE
  },
  [58] = {
    name = "Dodge",
    special = "DODGE",
    combatType = US_TYPES.DEFENSIVE,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 70,
    format = function(value)
      return "Dodge +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [59] = {
    name = "Damage Reflect",
    special = "REFLECT",
    combatType = US_TYPES.DEFENSIVE,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 70,
    format = function(value)
      return "Damage Reflect +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.SHIELD + US_ITEM_TYPES.ARMOR + US_ITEM_TYPES.HELMET + US_ITEM_TYPES.LEGS + US_ITEM_TYPES.BOOTS
  },
  [60] = {
    name = "Life Leech Chance",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SPECIALSKILL_LIFELEECHCHANCE,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 75,
    format = function(value)
      return "Life Leech Chance +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY
  },
  [61] = {
    name = "Life Leech Amount",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SPECIALSKILL_LIFELEECHAMOUNT,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 30,
    format = function(value)
      return "Life Leech Amount +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY
  },
  [62] = {
    name = "Mana Leech Chance",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SPECIALSKILL_MANALEECHCHANCE,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 75,
    format = function(value)
      return "Mana Leech Chance +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY
  },
  [63] = {
    name = "Mana Leech Amount",
    combatType = US_TYPES.CONDITION,
    condition = CONDITION_ATTRIBUTES,
    param = CONDITION_PARAM_SPECIALSKILL_MANALEECHAMOUNT,
    minLevel = 1,
    BASE_ITEM_LEVEL = 1,
    VALUE_TICK_EVERY = 30,
    format = function(value)
      return "Mana Leech Amount +" .. value .. "%%"
    end,
    itemType = US_ITEM_TYPES.WEAPON_ANY
  }
}

function exoriEffect(center, effect)
  for i = -1, 1 do
    local top = Position(center.x + i, center.y - 1, center.z)
    local middle = Position(center.x + i, center.y, center.z)
    local bottom = Position(center.x + i, center.y + 1, center.z)
    top:sendMagicEffect(effect)
    middle:sendMagicEffect(effect)
    bottom:sendMagicEffect(effect)
  end
end
