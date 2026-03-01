-- Auto-build armorsmith crafts from loaded item types.
-- This overrides static data/scripts/crafting/armorsmith.lua on startup.

if not Crafting then
    Crafting = {}
end

local MAX_ITEM_ID = 30000

local function itemExists(itemId)
    local it = ItemType(itemId)
    return it and it:getId() ~= 0 and it:getClientId() > 0
end

local materialSets = {
    helmet = {5890, 5880, 2147},
    armor = {5880, 5890, 2146},
    legs = {5880, 5885, 2149},
    boots = {5890, 5887, 2147},
    shield = {5880, 5890, 2146},
    others = {5881, 5887, 2149}
}

-- Manual helmet filters/recipes.
-- Rules:
-- 1) Remove from crafting every helmet obtainable via monster loot or quest reward.
-- 2) Keep craft-only helmets with custom recipes and costs.
local helmetOverrides = {
    [2323] = {
        cost = 5000,
        materials = {
            {id = 2301, count = 10}, -- fire field rune
            {id = 2311, count = 20}, -- heavy magic missile rune
            {id = 2302, count = 10} -- fireball rune
        }
    }, -- hat of the mad
    [2342] = {disabled = true}, -- helmet of the ancients
    [2343] = {disabled = true}, -- helmet of the ancients (variant)
    [2457] = {disabled = true}, -- steel helmet (drop+quest)
    [2458] = {disabled = true}, -- chain helmet (drop)
    [2459] = {disabled = true}, -- iron helmet (drop+quest)
    [2460] = {disabled = true}, -- brass helmet (drop+quest)
    [2461] = {disabled = true}, -- leather helmet (drop)
    [2462] = {disabled = true}, -- devil helmet (drop+quest)
    [2471] = {
        cost = 4500000,
        materials = {
            {id = 5827, count = 1}, -- zaoan helmet
            {id = 2466, count = 10}, -- golden armor
            {id = 2747, count = 25}, -- grave flower
            {id = 2560, count = 25}, -- mirror
            {id = 2194, count = 25}, -- mysterious fetish
            {id = 2176, count = 25} -- orb
        }
    }, -- golden helmet
    [2473] = {disabled = true}, -- viking helmet (drop+quest)
    [2474] = {
        cost = 4000000,
        materials = {
            {id = 2499, count = 1}, -- amazon helmet
            {id = 2747, count = 20}, -- grave flower
            {id = 2560, count = 20}, -- mirror
            {id = 2194, count = 20}, -- mysterious fetish
            {id = 2176, count = 20} -- orb
        }
    }, -- winged helmet
    [2475] = {disabled = true}, -- warrior helmet (drop+quest)
    [2479] = {disabled = true}, -- strange helmet (drop)
    [2480] = {disabled = true}, -- legion helmet (drop+quest)
    [2481] = {disabled = true}, -- soldier helmet (drop)
    [2482] = {disabled = true}, -- studded helmet (drop)
    [2490] = {disabled = true}, -- dark helmet (drop)
    [2491] = {disabled = true}, -- crown helmet (drop+quest)
    [2493] = {disabled = true}, -- demon helmet (quest)
    [2496] = {
        cost = 3500000,
        materials = {
            {id = 5827, count = 1}, -- zaoan helmet
            {id = 2645, count = 5}, -- steel boots
            {id = 2747, count = 20}, -- grave flower
            {id = 2560, count = 20}, -- mirror
            {id = 2194, count = 20}, -- mysterious fetish
            {id = 2176, count = 20} -- orb
        }
    }, -- horned helmet
    [2497] = {disabled = true}, -- crusader helmet (drop+quest)
    [2498] = {disabled = true}, -- royal helmet (drop)
    [2499] = {
        cost = 5000,
        materials = {
            {id = 2455, count = 20}, -- crossbow
            {id = 2490, count = 5}, -- dark helmet
            {id = 2747, count = 5}, -- grave flower
            {id = 2560, count = 5} -- mirror
        }
    }, -- amazon helmet
    [2501] = {disabled = true}, -- ceremonial mask
    [2502] = {
        cost = 5000,
        materials = {
            {id = 2457, count = 10}, -- steel helmet
            {id = 2747, count = 3}, -- grave flower
            {id = 2560, count = 3} -- mirror
        }
    }, -- dwarven helmet
    [2506] = {
        cost = 3000000,
        materials = {
            {id = 5827, count = 1}, -- zaoan helmet
            {id = 2492, count = 5}, -- dragon scale mail
            {id = 2747, count = 20}, -- grave flower
            {id = 2560, count = 20}, -- mirror
            {id = 2194, count = 20}, -- mysterious fetish
            {id = 2176, count = 20} -- orb
        }
    }, -- dragon scale helmet
    [2660] = {disabled = true}, -- hidden turbant
    [2662] = {
        cost = 50000,
        materials = {
            {id = 2323, count = 1}, -- hat of the mad
            {id = 2311, count = 60}, -- heavy magic missile rune
            {id = 2304, count = 60} -- great fireball rune
        }
    }, -- magician hat
    [2663] = {disabled = true}, -- mystic turban (drop)
    [2665] = {disabled = true}, -- post officers hat
    [3967] = {disabled = true}, -- tribal mask (drop)
    [3969] = {disabled = true}, -- horseman helmet (drop)
    [3970] = {cost = 500, materials = {}}, -- feather headdress (drop)
    [3971] = {disabled = true}, -- charmer tiara (drop)
    [3972] = {disabled = true}, -- beholder helmet (drop)
    [5735] = {disabled = true}, -- royal helmet (task reward variant)
    [5809] = {
        cost = 200000,
        materials = {
            {id = 2662, count = 1}, -- magician hat
            {id = 2268, count = 20}, -- sudden death rune
            {id = 2304, count = 100}, -- great fireball rune
            {id = 2313, count = 60}, -- explosion rune
            {id = 2273, count = 20}, -- ultimate healing rune
            {id = 2311, count = 40} -- heavy magic missile rune
        }
    }, -- yalahari mask
    [5827] = {
        cost = 80000,
        materials = {
            {id = 2502, count = 1}, -- dwarven helmet
            {id = 2747, count = 15}, -- grave flower
            {id = 2560, count = 15}, -- mirror
            {id = 2194, count = 15} -- mysterious fetish
        }
    }, -- zaoan helmet
    [5866] = {
        cost = 40000,
        materials = {
            {id = 2301, count = 100} -- fire field rune
        }
    }, -- magma monocle
    [5867] = {
        cost = 40000,
        materials = {
            {id = 2277, count = 100} -- energy field rune
        }
    }, -- lightning headband
    [5871] = {
        cost = 40000,
        materials = {
            {id = 2261, count = 100} -- destroy field rune
        }
    }, -- glacier mask
    [5882] = {
        cost = 40000,
        materials = {
            {id = 2285, count = 100} -- poison field rune
        }
    }, -- terra hood
    [6480] = {
        cost = 4000000,
        materials = {
            {id = 5809, count = 1}, -- yalahari mask
            {id = 2268, count = 100}, -- sudden death rune
            {id = 2273, count = 100}, -- ultimate healing rune
            {id = 2313, count = 100}, -- explosion rune
            {id = 2304, count = 200}, -- great fireball rune
            {id = 2311, count = 400} -- heavy magic missile rune
        }
    } -- ferumbras' hat
}

-- Keep craft-only helmet variants that are skipped by name-based deduplication
-- (e.g. blocked low-id variant exists with the same name).
-- Empty for now: 5735 is intentionally blocked.
local helmetExtraCrafts = {}

-- Manual armor/body filters/costs.
-- Based on armorsmith_chests_drop_report.txt:
-- disable all DROP/QUEST statuses, keep UNKNOWN as craft-only (cost only).
local armorOverrides = {
    [2500] = {
        cost = 50000,
        materials = {
            {id = 5829, count = 1}, -- paladin armor
            {id = 2074, count = 12}, -- panpipes
            {id = 1948, count = 12}, -- parchment
            {id = 2803, count = 12} -- powder herb
        }
    }, -- amazon armor
    [5828] = {
        cost = 1000000,
        materials = {
            {id = 2500, count = 1}, -- amazon armor
            {id = 2074, count = 15}, -- panpipes
            {id = 1948, count = 15}, -- parchment
            {id = 2803, count = 15}, -- powder herb
            {id = 1982, count = 15} -- purple tome
        }
    }, -- archer armor
    [2659] = {disabled = true}, -- ball gown
    [2656] = {disabled = true}, -- blue robe (drop+quest)
    [2465] = {disabled = true}, -- brass armor (drop+quest)
    [2654] = {disabled = true}, -- cape (drop)
    [2464] = {disabled = true}, -- chain armor (drop+quest)
    [2651] = {disabled = true}, -- coat (drop)
    [2487] = {disabled = true}, -- crown armor (drop+quest)
    [2489] = {disabled = true}, -- dark armor (drop+quest)
    [2494] = {
        cost = 3000000,
        materials = {
            {id = 2520, count = 10}, -- demon shield
            {id = 2074, count = 20}, -- panpipes
            {id = 1948, count = 20}, -- parchment
            {id = 2803, count = 20}, -- powder herb
            {id = 1982, count = 20} -- purple tome
        }
    }, -- demon armor
    [2485] = {disabled = true}, -- doublet (quest)
    [2492] = {disabled = true}, -- dragon scale mail (drop+quest)
    [2503] = {
        cost = 5000,
        materials = {
            {id = 2463, count = 5}, -- plate armor
            {id = 2074, count = 5}, -- panpipes
            {id = 1948, count = 5} -- parchment
        }
    }, -- dwarven armor
    [2505] = {
        cost = 2000000,
        materials = {
            {id = 5862, count = 1}, -- magma coat
            {id = 2304, count = 400} -- great fireball rune
        }
    }, -- firemasters armor
    [2664] = {
        cost = 2000000,
        materials = {
            {id = 5862, count = 1}, -- magma coat
            {id = 2304, count = 400} -- great fireball rune
        }
    }, -- firemasters armor (alt id)
    [5872] = {
        cost = 40000,
        materials = {
            {id = 2261, count = 100} -- destroy field rune
        }
    }, -- glacier robe
    [2466] = {disabled = true}, -- golden armor (drop+quest)
    [2652] = {disabled = true}, -- green tunic (drop)
    [2650] = {disabled = true}, -- jacket
    [2476] = {disabled = true}, -- knight armor (drop+quest)
    [2467] = {disabled = true}, -- leather armor (drop+quest)
    [3968] = {
        cost = 4000,
        materials = {
            {id = 2463, count = 1}, -- plate armor
            {id = 2074, count = 5}, -- panpipes
            {id = 1948, count = 5} -- parchment
        }
    }, -- leopard armor
    [5868] = {
        cost = 40000,
        materials = {
            {id = 2277, count = 100} -- energy field rune
        }
    }, -- lightning robe
    [2472] = {disabled = true}, -- magic plate armor (drop)
    [5733] = {disabled = true}, -- magic plate armor (alt id)
    [5862] = {
        cost = 40000,
        materials = {
            {id = 2301, count = 100} -- fire field rune
        }
    }, -- magma coat
    [2508] = {disabled = true}, -- native armor
    [2486] = {disabled = true}, -- noble armor (drop+quest)
    [5829] = {
        cost = 25000,
        materials = {
            {id = 3968, count = 1}, -- leopard armor
            {id = 2074, count = 8}, -- panpipes
            {id = 1948, count = 8}, -- parchment
            {id = 2803, count = 8} -- powder herb
        }
    }, -- paladin armor
    [2463] = {disabled = true}, -- plate armor (drop+quest)
    [2655] = {
        cost = 1500,
        materials = {
            {id = 2301, count = 10} -- fire field rune
        }
    }, -- red robe
    [2653] = {cost = 600, materials = {}}, -- red tunic
    [2483] = {disabled = true}, -- scale armor (drop+quest)
    [2657] = {disabled = true}, -- simple dress (drop)
    [4847] = {cost = 100}, -- simple dress (duplicate id variant)
    [5784] = {
        cost = 1500000,
        materials = {
            {id = 2268, count = 200} -- sudden death rune
        }
    }, -- skullcracker armor
    [5816] = {
        cost = 2000000,
        materials = {
            {id = 2268, count = 250} -- sudden death rune
        }
    }, -- skullmaster armor
    [2484] = {disabled = true}, -- studded armor (drop)
    [5881] = {
        cost = 40000,
        materials = {
            {id = 2285, count = 100} -- poison field rune
        }
    }, -- terra mantle
    [2658] = {disabled = true}, -- white dress
    [5807] = {
        cost = 2000000,
        materials = {
            {id = 2503, count = 1}, -- dwarven armor
            {id = 2074, count = 20}, -- panpipes
            {id = 1948, count = 20}, -- parchment
            {id = 2803, count = 20}, -- powder herb
            {id = 1982, count = 20} -- purple tome
        }
    }, -- yalahari armor
    [5826] = {
        cost = 25000,
        materials = {
            {id = 2486, count = 1}, -- noble armor
            {id = 2074, count = 8}, -- panpipes
            {id = 1948, count = 8}, -- parchment
            {id = 2803, count = 8} -- powder herb
        }
    } -- zaoan armor
}

-- Manual legs filters/costs.
-- Based on armorsmith_legs_drop_report.txt:
-- disable all DROP/QUEST statuses, keep UNKNOWN as craft-only (cost only).
local legsOverrides = {
    [3983] = {disabled = true}, -- bast skirt (drop)
    [5728] = {
        cost = 200000,
        materials = {
            {id = 2647, count = 5}, -- plate legs
            {id = 2804, count = 15}, -- shadow herb
            {id = 2159, count = 15}, -- scarab coin
            {id = 2134, count = 15}, -- silver brooch
            {id = 2229, count = 15} -- skull
        }
    }, -- blue legs
    [2478] = {cost = 500, materials = {}}, -- brass legs (drop+quest)
    [2648] = {disabled = true}, -- chain legs (drop)
    [2488] = {disabled = true}, -- crown legs (drop+quest)
    [2495] = {
        cost = 3000000,
        materials = {
            {id = 2520, count = 10}, -- demon shield
            {id = 2804, count = 20}, -- shadow herb
            {id = 2159, count = 20}, -- scarab coin
            {id = 2134, count = 20}, -- silver brooch
            {id = 2229, count = 20} -- skull
        }
    }, -- demon legs
    [2469] = {
        cost = 3000000,
        materials = {
            {id = 2492, count = 10}, -- dragon scale mail
            {id = 2804, count = 20}, -- shadow herb
            {id = 2159, count = 20}, -- scarab coin
            {id = 2134, count = 20}, -- silver brooch
            {id = 2229, count = 20} -- skull
        }
    }, -- dragon scale legs
    [2504] = {
        cost = 8000,
        materials = {
            {id = 2647, count = 5}, -- plate legs
            {id = 2804, count = 5}, -- shadow herb
            {id = 2159, count = 5} -- scarab coin
        }
    }, -- dwarven legs
    [5873] = {
        cost = 40000,
        materials = {
            {id = 2261, count = 100} -- destroy field rune
        }
    }, -- glacier kilt
    [2470] = {disabled = true}, -- golden legs (drop)
    [2507] = {
        cost = 1000000,
        materials = {
            {id = 5808, count = 1}, -- yalahari leg piece
            {id = 2804, count = 15}, -- shadow herb
            {id = 2159, count = 15}, -- scarab coin
            {id = 2134, count = 15}, -- silver brooch
            {id = 2229, count = 15} -- skull
        }
    }, -- green legs
    [2477] = {disabled = true}, -- knight legs (drop+quest)
    [2649] = {disabled = true}, -- leather legs (drop)
    [5869] = {
        cost = 40000,
        materials = {
            {id = 2277, count = 100} -- energy field rune
        }
    }, -- lightning legs
    [5863] = {
        cost = 40000,
        materials = {
            {id = 2301, count = 100} -- fire field rune
        }
    }, -- magma legs
    [2647] = {disabled = true}, -- plate legs (drop+quest)
    [2468] = {disabled = true}, -- studded legs (drop)
    [5880] = {
        cost = 40000,
        materials = {
            {id = 2285, count = 100} -- poison field rune
        }
    }, -- terra legs
    [5808] = {
        cost = 18000,
        materials = {
            {id = 2647, count = 5}, -- plate legs
            {id = 2804, count = 5}, -- shadow herb
            {id = 2159, count = 5} -- scarab coin
        }
    }, -- yalahari leg piece
    [5839] = {
        cost = 30000,
        materials = {
            {id = 2504, count = 1}, -- dwarven legs
            {id = 2804, count = 8}, -- shadow herb
            {id = 2159, count = 8}, -- scarab coin
            {id = 2134, count = 8} -- silver brooch
        }
    } -- zaoan legs
}

-- Manual boots/feet filters/costs.
-- Based on armorsmith_boots_drop_report.txt:
-- disable all DROP/QUEST statuses, keep UNKNOWN as craft-only (cost only).
local bootsOverrides = {
    [2195] = {disabled = true}, -- boots of haste (drop+quest)
    [2644] = {cost = 250000, materials = {}}, -- bunny slippers
    [3982] = {disabled = true}, -- crocodile boots (drop)
    [5874] = {
        cost = 40000,
        materials = {
            {id = 2261, count = 100} -- destroy field rune
        }
    }, -- glacier shoes
    [2646] = {
        cost = 2650000,
        materials = {
            {id = 5838, count = 5}, -- zaoan shoes
            {id = 2195, count = 3}, -- boots of haste
            {id = 2802, count = 20}, -- sling herb
            {id = 2062, count = 20}, -- small oil lamp
            {id = 2354, count = 20}, -- soul ankh
            {id = 6437, count = 20} -- soul orb
        }
    }, -- golden boots
    [2643] = {disabled = true}, -- leather boots (drop)
    [5870] = {
        cost = 40000,
        materials = {
            {id = 2277, count = 100} -- energy field rune
        }
    }, -- lightning boots
    [5864] = {
        cost = 40000,
        materials = {
            {id = 2301, count = 100} -- fire field rune
        }
    }, -- magma boots
    [5798] = {
        cost = 200000,
        materials = {
            {id = 5874, count = 1}, -- glacier shoes
            {id = 5870, count = 1}, -- lightning boots
            {id = 5864, count = 1}, -- magma boots
            {id = 5879, count = 1} -- terra boots
        }
    }, -- oriental shoes
    [2358] = {disabled = true}, -- pair of soft boots (quest)
    [2640] = {disabled = true}, -- pair of soft boots (quest)
    [2645] = {disabled = true}, -- steel boots (drop+quest)
    [5879] = {
        cost = 40000,
        materials = {
            {id = 2285, count = 100} -- poison field rune
        }
    }, -- terra boots
    [2641] = {disabled = true}, -- worn soft boots
    [5729] = {disabled = true}, -- worn soft boots
    [5838] = {
        cost = 15000,
        materials = {
            {id = 2802, count = 2}, -- sling herb
            {id = 2062, count = 2}, -- small oil lamp
            {id = 2354, count = 2}, -- soul ankh
            {id = 6437, count = 2} -- soul orb
        }
    } -- zaoan shoes
}

-- Manual shield/spellbook filters/costs.
-- Remapped against current sources:
-- data/monster/*.xml + quest reward scripts (data/actions/scripts, data/scripts/actions).
-- If item id appears in loot OR quest reward patterns, disable it.
local shieldOverrides = {
    [2537] = {
        cost = 8000,
        materials = {
            {id = 2538, count = 1}, -- eagle shield
            {id = 2174, count = 4}, -- strange symbol
            {id = 2151, count = 4} -- talon
        }
    }, -- amazon shield
    [2532] = {disabled = true}, -- ancient shield (drop)
    [2513] = {disabled = true}, -- battle shield (drop)
    [2518] = {disabled = true}, -- beholder shield (drop)
    [2529] = {disabled = true}, -- black shield (drop)
    [2523] = {
        cost = 3000000,
        materials = {
            {id = 5539, count = 1}, -- shield of dorion
            {id = 2514, count = 3}, -- mastermind shield
            {id = 2174, count = 15}, -- strange symbol
            {id = 2151, count = 15}, -- talon
            {id = 2245, count = 15}, -- twigs
            {id = 3955, count = 15} -- voodoo doll
        }
    }, -- blessed shield
	    [7961] = {
	        cost = 3000000,
	        materials = {
	            {id = 5812, count = 1}, -- lizard knowledge spellbook
	            {id = 2268, count = 200}, -- sudden death rune
	            {id = 2273, count = 200}, -- ultimate healing rune
	            {id = 2174, count = 20}, -- strange symbol
	            {id = 2151, count = 20}, -- talon
	            {id = 2245, count = 20} -- twigs
	        }
	    }, -- revive spellbook
    [2541] = {cost = 600, materials = {}}, -- bone shield (drop)
    [2511] = {disabled = true}, -- brass shield (drop)
    [2535] = {disabled = true}, -- castle shield (drop)
    [2530] = {disabled = true}, -- copper shield (drop+quest)
    [2519] = {disabled = true}, -- crown shield (quest)
    [2521] = {disabled = true}, -- dark shield (quest)
    [2520] = {disabled = true}, -- demon shield (quest)
    [2516] = {disabled = true}, -- dragon shield (drop)
    [2525] = {disabled = true}, -- dwarven shield (quest)
    [2538] = {
        cost = 3000,
        materials = {
            {id = 2533, count = 1}, -- mercenary shield
            {id = 2174, count = 4}, -- strange symbol
            {id = 2151, count = 4} -- talon
        }
    }, -- eagle shield
    [2522] = {
        cost = 2000000,
        materials = {
            {id = 5539, count = 1}, -- shield of dorion
            {id = 2514, count = 1}, -- mastermind shield
            {id = 2174, count = 15}, -- strange symbol
            {id = 2151, count = 15}, -- talon
            {id = 2245, count = 15}, -- twigs
            {id = 3955, count = 15} -- voodoo doll
        }
    }, -- great shield
    [2515] = {disabled = true}, -- guardian shield (drop)
    [5812] = {
        cost = 1000000,
        materials = {
            {id = 5791, count = 1}, -- warlocks spellbook
            {id = 2268, count = 100}, -- sudden death rune
            {id = 2273, count = 100}, -- ultimate healing rune
            {id = 2174, count = 15}, -- strange symbol
            {id = 2151, count = 15}, -- talon
            {id = 2245, count = 15} -- twigs
        }
    }, -- lizard knowledge spellbook
    [5865] = {
        cost = 40000,
        materials = {
            {id = 2301, count = 100} -- fire field rune
        }
    }, -- magma shield
    [2514] = {disabled = true}, -- mastermind shield (drop+quest)
    [2536] = {disabled = true}, -- medusa shield (drop+quest)
    [2533] = {
        cost = 1500,
        materials = {
            {id = 2527, count = 1}, -- rose shield
            {id = 2174, count = 4}, -- strange symbol
            {id = 2151, count = 4} -- talon
        }
    }, -- mercenary shield
    [5789] = {
        cost = 38000,
        materials = {
            {id = 5920, count = 1}, -- spellbook of mind control
            {id = 2277, count = 20}, -- energy field rune
            {id = 2174, count = 2} -- strange symbol
        }
    }, -- necromantic spellbook
    [2524] = {disabled = true}, -- ornamented shield (drop+quest)
    [2539] = {
        cost = 15000,
        materials = {
            {id = 2517, count = 1}, -- shield of honour
            {id = 2174, count = 6}, -- strange symbol
            {id = 2151, count = 6} -- talon
        }
    }, -- phoenix shield
    [2510] = {disabled = true}, -- plate shield (drop)
    [2527] = {
        cost = 800,
        materials = {
            {id = 2525, count = 1}, -- dwarven shield
            {id = 2174, count = 2}, -- strange symbol
            {id = 2151, count = 2} -- talon
        }
    }, -- rose shield
    [3975] = {disabled = true}, -- salamander shield (drop)
    [2540] = {disabled = true}, -- scarab shield (drop)
    [3974] = {disabled = true}, -- sentinel shield (drop)
    [5539] = {
        cost = 140000,
        materials = {
            {id = 2539, count = 1}, -- phoenix shield
            {id = 2174, count = 10}, -- strange symbol
            {id = 2151, count = 10}, -- talon
            {id = 2245, count = 10} -- twigs
        }
    }, -- shield of dorion
    [2517] = {
        cost = 12000,
        materials = {
            {id = 2537, count = 1}, -- amazon shield
            {id = 2174, count = 4}, -- strange symbol
            {id = 2151, count = 4} -- talon
        }
    }, -- shield of honour
    [2175] = {disabled = true}, -- spellbook (drop+quest)
    [5920] = {
        cost = 15000,
        materials = {
            {id = 5918, count = 1}, -- spellscroll of prophecies
            {id = 2301, count = 20} -- fire field rune
        }
    }, -- spellbook of mind control
    [5918] = {
        cost = 5000,
        materials = {
            {id = 2175, count = 5} -- spellbook
        }
    }, -- spellscroll of prophecies
    [2509] = {disabled = true}, -- steel shield (quest)
    [2526] = {disabled = true}, -- studded shield (drop)
    [2542] = {disabled = true}, -- tempest shield
    [2528] = {disabled = true}, -- tower shield (quest)
    [3973] = {disabled = true}, -- tusk shield (drop)
    [2534] = {disabled = true}, -- vampire shield (quest)
    [5732] = {disabled = true}, -- vampire shield (alt id)
    [2531] = {disabled = true}, -- viking shield (craft-only)
    [5791] = {
        cost = 90000,
        materials = {
            {id = 5789, count = 1}, -- necromantic spellbook
            {id = 2268, count = 20}, -- sudden death rune
            {id = 2273, count = 20}, -- ultimate healing rune
            {id = 2174, count = 5}, -- strange symbol
            {id = 2151, count = 5} -- talon
        }
    }, -- warlocks spellbook
    [2512] = {disabled = true} -- wooden shield (drop)
}

-- Manual overrides for "others" category.
local othersOverrides = {
    [7088] = {disabled = true}, -- regeneration amulet
    [2661] = {disabled = true}, -- scarf
    [2171] = {disabled = true}, -- platinum amulet
    [2339] = {disabled = true}, -- damaged helmet
    [7956] = {
        cost = 4000,
        materials = {
            {id = 2456, count = 1}, -- bow
            {id = 2455, count = 1}, -- crossbow
            {id = 2544, count = 100}, -- arrow
            {id = 2543, count = 100} -- bolt
        }
    }, -- small quiver
    [7957] = {
        cost = 20000,
        materials = {
            {id = 7956, count = 1}, -- small quiver
            {id = 2074, count = 2}, -- panpipes
            {id = 2804, count = 2} -- shadow herb
        }
    }, -- quiver
    [7958] = {
        cost = 100000,
        materials = {
            {id = 7957, count = 1}, -- quiver
            {id = 2074, count = 5}, -- panpipes
            {id = 2804, count = 5}, -- shadow herb
            {id = 2802, count = 5} -- sling herb
        }
    }, -- red quiver
    [7959] = {
        cost = 500000,
        materials = {
            {id = 7958, count = 1}, -- red quiver
            {id = 2074, count = 10}, -- panpipes
            {id = 2804, count = 10}, -- shadow herb
            {id = 2802, count = 10} -- sling herb
        }
    }, -- jungle quiver
    [7960] = {
        cost = 2500000,
        materials = {
            {id = 7959, count = 1}, -- jungle quiver
            {id = 2074, count = 15}, -- panpipes
            {id = 2804, count = 15}, -- shadow herb
            {id = 2802, count = 15}, -- sling herb
            {id = 2174, count = 15} -- strange symbol
        }
    } -- alicorn quiver
}

-- Items for armorsmith "others" that are not auto-detected as armor.
local othersExtraCrafts = {
    [7956] = {
        cost = 4000,
        level = 8,
        materials = {
            {id = 2456, count = 1}, -- bow
            {id = 2455, count = 1}, -- crossbow
            {id = 2544, count = 100}, -- arrow
            {id = 2543, count = 100} -- bolt
        }
    }, -- small quiver
    [7957] = {
        cost = 20000,
        level = 14,
        materials = {
            {id = 7956, count = 1}, -- small quiver
            {id = 2074, count = 2}, -- panpipes
            {id = 2804, count = 2} -- shadow herb
        }
    }, -- quiver
    [7958] = {
        cost = 100000,
        level = 20,
        materials = {
            {id = 7957, count = 1}, -- quiver
            {id = 2074, count = 5}, -- panpipes
            {id = 2804, count = 5}, -- shadow herb
            {id = 2802, count = 5} -- sling herb
        }
    }, -- red quiver
    [7959] = {
        cost = 500000,
        level = 28,
        materials = {
            {id = 7958, count = 1}, -- red quiver
            {id = 2074, count = 10}, -- panpipes
            {id = 2804, count = 10}, -- shadow herb
            {id = 2802, count = 10} -- sling herb
        }
    }, -- jungle quiver
    [7960] = {
        cost = 2500000,
        level = 36,
        materials = {
            {id = 7959, count = 1}, -- jungle quiver
            {id = 2074, count = 15}, -- panpipes
            {id = 2804, count = 15}, -- shadow herb
            {id = 2802, count = 15}, -- sling herb
            {id = 2174, count = 15} -- strange symbol
        }
    } -- alicorn quiver
}

local function getArmorGroup(itemType)
    if itemType:isHelmet() then
        return "helmet"
    elseif itemType:isArmor() then
        return "armor"
    elseif itemType:isLegs() then
        return "legs"
    elseif itemType:isBoots() then
        return "boots"
    elseif itemType:isShield() then
        return "shield"
    end
    return "others"
end

local function isArmorCandidate(itemType)
    if not itemType or itemType:getId() == 0 or itemType:getClientId() <= 0 then
        return false
    end

    if not itemType:isMovable() then
        return false
    end

    local weaponType = itemType:getWeaponType()
    if weaponType == WEAPON_SWORD or weaponType == WEAPON_AXE or weaponType == WEAPON_CLUB or weaponType == WEAPON_DISTANCE or
        weaponType == WEAPON_WAND or weaponType == WEAPON_AMMO then
        return false
    end

    if itemType:isHelmet() or itemType:isArmor() or itemType:isLegs() or itemType:isBoots() or itemType:isShield() then
        return true
    end

    local armor = math.max(0, itemType:getArmor())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())
    return armor > 0 or defense > 0
end

local function computeLevel(itemType, group)
    local armor = math.max(0, itemType:getArmor())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())

    local power = armor * 2.0 + defense * 1.5
    if group == "shield" then
        power = armor * 1.5 + defense * 2.2
    elseif group == "boots" then
        power = armor * 1.8 + defense * 1.2
    end

    local level = math.floor(power * 2.2)
    return math.max(8, math.min(120, level))
end

local function computeCost(itemType, level, group)
    local armor = math.max(0, itemType:getArmor())
    local defense = math.max(0, itemType:getDefense() + itemType:getExtraDefense())

    local cost = 250 + (level * level * 3) + (armor * 140) + (defense * 90)
    if group == "shield" then
        cost = math.floor(cost * 1.15)
    end

    return math.max(250, math.floor((cost + 25) / 50) * 50)
end

local function buildMaterials(group, level)
    local base = materialSets[group] or materialSets.others
    local mats = {}

    local c1 = math.max(2, math.floor(level / 10) + 2)
    local c2 = math.max(1, math.floor(level / 20) + 1)
    local c3 = math.max(1, math.floor(level / 35) + 1)

    if itemExists(base[1]) then
        table.insert(mats, {id = base[1], count = c1})
    end
    if itemExists(base[2]) then
        table.insert(mats, {id = base[2], count = c2})
    end
    if level >= 45 and itemExists(base[3]) then
        table.insert(mats, {id = base[3], count = c3})
    end

    if #mats == 0 then
        mats[1] = {id = 2148, count = math.max(5, math.floor(level / 4))}
    end

    return mats
end

local function generateArmorsmithCrafts()
    local crafts = {}
    local seen = {}

    for itemId = 100, MAX_ITEM_ID do
        local it = ItemType(itemId)
        if isArmorCandidate(it) then
            local name = it:getName()
            if name and name ~= "" then
                local group = getArmorGroup(it)
                local key = group .. ":" .. name:lower()
                if not seen[key] then
                    seen[key] = true
                    local level = computeLevel(it, group)
                    table.insert(
                        crafts,
                        {
                            id = itemId,
                            name = name,
                            armorType = group,
                            level = level,
                            cost = computeCost(it, level, group),
                            count = 1,
                            materials = buildMaterials(group, level)
                        }
                    )
                end
            end
        end
    end

    table.sort(
        crafts,
        function(a, b)
            if a.level ~= b.level then
                return a.level < b.level
            end
            return a.name:lower() < b.name:lower()
        end
    )

    return crafts
end

local function applyOverrideSet(crafts, overrides)
    local byId = {}
    for i = 1, #crafts do
        local craft = crafts[i]
        if type(craft) == "table" and craft.id then
            byId[craft.id] = i
        end
    end

    for itemId, override in pairs(overrides) do
        local idx = byId[itemId]
        if idx then
            local craft = crafts[idx]
            if type(craft) == "table" then
                if override.disabled then
                    crafts[idx] = false
                else
                    if override.count ~= nil then
                        craft.count = math.max(1, tonumber(override.count) or craft.count or 1)
                    end

                    if override.cost ~= nil then
                        craft.cost = math.max(0, tonumber(override.cost) or craft.cost)
                    end

                    if override.recipes ~= nil then
                        local recipes = {}
                        for i = 1, #override.recipes do
                            local recipe = override.recipes[i]
                            local recipeMats = {}
                            for x = 1, #(recipe.materials or {}) do
                                local mat = recipe.materials[x]
                                local matId = tonumber(mat.id)
                                local matCount = tonumber(mat.count)
                                if matId and matId > 0 and matCount and matCount > 0 and itemExists(matId) then
                                    recipeMats[#recipeMats + 1] = {id = matId, count = matCount}
                                end
                            end
                            recipes[#recipes + 1] = {
                                cost = math.max(0, tonumber(recipe.cost) or craft.cost),
                                count = math.max(1, tonumber(recipe.count) or craft.count or 1),
                                materials = recipeMats
                            }
                        end
                        craft.recipes = recipes
                        if recipes[1] then
                            craft.cost = recipes[1].cost
                            craft.count = recipes[1].count or craft.count
                            craft.materials = recipes[1].materials
                        end
                    elseif override.materials ~= nil then
                        local mats = {}
                        for i = 1, #override.materials do
                            local mat = override.materials[i]
                            local matId = tonumber(mat.id)
                            local matCount = tonumber(mat.count)
                            if matId and matId > 0 and matCount and matCount > 0 and itemExists(matId) then
                                mats[#mats + 1] = {id = matId, count = matCount}
                            end
                        end
                        craft.materials = mats
                        craft.recipes = nil
                    end
                end
            end
        end
    end
end

local function appendExtraHelmetCrafts(crafts)
    local byId = {}
    for i = 1, #crafts do
        local craft = crafts[i]
        if type(craft) == "table" and craft.id then
            byId[craft.id] = true
        end
    end

    for itemId, extra in pairs(helmetExtraCrafts) do
        if not (type(extra) == "table" and extra.disabled) and not byId[itemId] and itemExists(itemId) then
            local it = ItemType(itemId)
            local level = computeLevel(it, "helmet")
            table.insert(
                crafts,
                {
                    id = itemId,
                    name = it:getName(),
                    armorType = "helmet",
                    level = level,
                    cost = math.max(0, tonumber(extra.cost) or computeCost(it, level, "helmet")),
                    count = 1,
                    materials = {}
                }
            )
        end
    end
end

local function appendExtraOthersCrafts(crafts)
    local byId = {}
    for i = 1, #crafts do
        local craft = crafts[i]
        if type(craft) == "table" and craft.id then
            byId[craft.id] = true
        end
    end

    for itemId, extra in pairs(othersExtraCrafts) do
        if not byId[itemId] and itemExists(itemId) then
            local it = ItemType(itemId)
            local mats = {}
            for i = 1, #(extra.materials or {}) do
                local mat = extra.materials[i]
                local matId = tonumber(mat.id)
                local matCount = tonumber(mat.count)
                if matId and matId > 0 and matCount and matCount > 0 and itemExists(matId) then
                    mats[#mats + 1] = {id = matId, count = matCount}
                end
            end
            table.insert(
                crafts,
                {
                    id = itemId,
                    name = it:getName(),
                    armorType = "others",
                    level = math.max(1, tonumber(extra.level) or 1),
                    cost = math.max(0, tonumber(extra.cost) or 0),
                    count = 1,
                    materials = mats
                }
            )
        end
    end
end

local function applyManualOverrides(crafts)
    applyOverrideSet(crafts, helmetOverrides)
    appendExtraHelmetCrafts(crafts)
    applyOverrideSet(crafts, armorOverrides)
    applyOverrideSet(crafts, legsOverrides)
    applyOverrideSet(crafts, bootsOverrides)
    applyOverrideSet(crafts, shieldOverrides)
    applyOverrideSet(crafts, othersOverrides)
    appendExtraOthersCrafts(crafts)

    local filtered = {}
    for i = 1, #crafts do
        if crafts[i] then
            filtered[#filtered + 1] = crafts[i]
        end
    end
    return filtered
end

local generated = generateArmorsmithCrafts()
generated = applyManualOverrides(generated)
if #generated > 0 then
    Crafting.armorsmith = generated
    print(string.format("[CraftingArmorsmithAuto] generated=%d", #generated))
else
    print("[CraftingArmorsmithAuto] generated=0 (kept existing armorsmith list)")
end
