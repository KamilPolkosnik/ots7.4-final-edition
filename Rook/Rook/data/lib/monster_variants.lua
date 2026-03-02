MonsterVariants = {
  enabled = true,

  -- Chance is in percent and processed in order (total can be <= 100).
  -- multiplier: 1.5 = +50%, 2.0 = +100%, 5.0 = +400%
  -- lootRolls: how many times to generate full loot table
  tiers = {
    { id = 1, chance = 5, multiplier = 1.5, effect = 15, lootMultiplier = 1.5, lootRolls = 2 }, -- green skull
    { id = 2, chance = 3, multiplier = 2.0, effect = 13, lootMultiplier = 2.0, lootRolls = 3 }, -- yellow skull
    { id = 3, chance = 1, multiplier = 5.0, effect = 15, lootMultiplier = 3.0, lootRolls = 5 }  -- red skull
  },

  excludeBosses = true,
  excludeSummons = true,
  excludeUnhostile = true,
  skipStartupSpawns = false,

  -- Optional filters
  -- allowedNames = { ["Vampire"] = true, ["Dragon"] = true }
  -- excludedNames = { ["Training Monk"] = true }

  storage = 45000,

  -- Re-emit magic effect while the monster is alive (ms). Set to 0 to disable.
  effectInterval = 500
}
