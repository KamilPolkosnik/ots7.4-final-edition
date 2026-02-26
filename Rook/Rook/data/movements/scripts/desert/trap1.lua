local effectToPlayer = 9
local effectToOthers = 9
local debuggingEnabled = true

local traps = {
    [1451] = { -- obelisk
        damage = {-1, -150}
    },
    [1562] = { -- obelisk
        damage = {-60, -60}
    },
    [1563] = { -- obelisk
        damage = {-30, -30}
    },
    [1560] = { -- poison tower
        damage = {-1, -14},
        type = COMBAT_EARTHDAMAGE
    },
    [1551] = { -- fire tower
        damage = {-1, -28},
        type = COMBAT_FIREDAMAGE
    }
}

function enableDebugging()
    debuggingEnabled = true
    print("Debugging enabled.")
end

function disableDebugging()
    debuggingEnabled = false
    print("Debugging disabled.")
end

function onStepIn(creature, item, position, fromPosition)
    local pos = position
    pos.y = pos.y - 1 -- Check the tile below the player's position
    
    local tile = Tile(pos)
    if tile then
        local topItem = tile:getTopTopItem()
        if topItem then
            local itemId = topItem.itemid
            local trap = traps[itemId]
            if trap then
                local damageType = trap.type or COMBAT_PHYSICALDAMAGE
                local minDamage, maxDamage = trap.damage[1], trap.damage[2]
                if debuggingEnabled then
                    print("Trap ID:", itemId)
                    print("Damage Type:", damageType)
                    print("Min Damage:", minDamage)
                    print("Max Damage:", maxDamage)
                    print("Position (x, y, z):", pos.x, pos.y, pos.z)
                    print("Target: Creature:", creature:getName())
                end
                doTargetCombat(0, creature, damageType, math.random(minDamage, maxDamage), math.random(minDamage, maxDamage), CONST_ME_NONE, true, false, false)
                item:transform(417) -- Transform the item to 417
            else
                if debuggingEnabled then
                    print("No trap found with ID:", itemId)
                end
            end
        else
            if debuggingEnabled then
                print("No top item found on tile:", pos)
            end
        end
    else
        if debuggingEnabled then
            print("Tile not found at position:", pos)
        end
    end
end

function onStepOut(creature, item, position, toPosition)
    if debuggingEnabled then
        print("Player stepped out at position:", position)
        print("Position (x, y, z):", position.x, position.y, position.z)
    end
    creature:getPosition():sendMagicEffect(15) -- Send effect 15 to player's position
    item:transform(416) -- Transform the item to 416
end
