local ATTR_DOUBLE_DAMAGE = 51

local function parseChance(param)
    local chance = tonumber(param)
    if not chance then
        return 10
    end
    if chance < 1 then
        chance = 1
    elseif chance > 100 then
        chance = 100
    end
    return chance
end

local function findSlotForAttr(item, attrId)
    local maxSlots = item:getMaxAttributes()
    local firstEmpty = nil
    for i = 1, maxSlots do
        local raw = item:getCustomAttribute("Slot" .. i)
        if raw then
            local first = raw:match("^([^|]+)")
            if tonumber(first) == attrId then
                return i, true
            end
        elseif not firstEmpty then
            firstEmpty = i
        end
    end
    return firstEmpty, false
end

function onSay(player, words, param)
    local item = player:getSlotItem(CONST_SLOT_RIGHT)
    if not item then
        item = player:getSlotItem(CONST_SLOT_LEFT)
    end

    if not item then
        player:sendTextMessage(MESSAGE_STATUS_SMALL, "Equip a weapon in your hand first.")
        return false
    end

    local chance = parseChance(param)

    if item.setRarity then
        item:setRarity(EPIC)
    else
        item:setCustomAttribute("rarity", EPIC)
    end

    local slot, updated = findSlotForAttr(item, ATTR_DOUBLE_DAMAGE)
    if not slot then
        slot = 1
        updated = item:getCustomAttribute("Slot1") ~= nil
    end

    item:setCustomAttribute("Slot" .. slot, string.format("%d|%d", ATTR_DOUBLE_DAMAGE, chance))

    local msg = updated and "Updated" or "Added"
    player:sendTextMessage(MESSAGE_STATUS_SMALL, msg .. " epic double-damage bonus (" .. chance .. "%) in slot " .. slot .. ".")
    return false
end
