local itemID = 1549
local effectToPlayer = 13
local effectToOthers = 14
local respawnDelay = 30 -- in seconds
local debuggingEnabled = true

function removeItemFromPosition(pos, itemID)
    local tile = Tile(pos)
    if tile then
        local item = tile:getItemById(itemID)
        if item then
            if debuggingEnabled then
                print("Item removed from position:", pos)
            end
            item:remove()
            return true
        end
    end
    if debuggingEnabled then
        print("Item not found at position:", pos)
    end
    return false
end

function addItemToPosition(pos, itemID)
    local tile = Tile(pos)
    if tile then
        if tile:getItemCountById(itemID) == 0 then
            Game.createItem(itemID, 1, pos)
            if debuggingEnabled then
                print("Item added to position:", pos)
            end
        else
            if debuggingEnabled then
                print("Item already exists at position:", pos)
            end
        end
    end
end

function onStepIn(creature, item, position, fromPosition)
    for x = 4708, 4713 do
        local pos = Position(x, 3149, 8)
        if removeItemFromPosition(pos, itemID) then
            if debuggingEnabled then
                print("Item removed at position:", pos)
            end
            pos:sendMagicEffect(effectToPlayer)
            addEvent(function()
                if debuggingEnabled then
                    print("Adding item at position:", pos)
                end
                addItemToPosition(pos, itemID)
            end, respawnDelay * 1000)
            if debuggingEnabled then
                print("Item re-creation queued at position:", pos, "with respawn delay:", respawnDelay)
            end
        end
    end
    creature:getPosition():sendMagicEffect(15) -- Send effect 15 to player's position
    item:transform(417) -- Transform the item to 417
    if debuggingEnabled then
        print("Item transformed to 417 at position:", position)
    end
end

function onStepOut(creature, item, position, toPosition)
    creature:getPosition():sendMagicEffect(14) -- Send effect 14 to player's position
    item:transform(416) -- Transform the item to 416
    if debuggingEnabled then
        print("Item transformed to 416 at position:", position)
    end
end


