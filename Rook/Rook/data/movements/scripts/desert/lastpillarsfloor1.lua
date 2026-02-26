local itemID = 1549
local effectToPlayer = 13
local effectToOthers = 14
local respawnDelay = 45 -- in seconds
local debuggingEnabled = true

-- Create the haste condition object
local haste = createConditionObject(CONDITION_HASTE)
setConditionParam(haste, CONDITION_PARAM_TICKS, 30 * 1000) -- Haste duration in milliseconds
setConditionParam(haste, CONDITION_PARAM_SPEED, 100) -- Haste speed boost (default is 200)
setConditionParam(haste, CONDITION_PARAM_SUBID, 1) -- SubID of the haste condition

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
    for y = 3169, 3171 do
        local pos = Position(4650, y, 8)
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
    
    -- Apply haste condition only if the player doesn't already have it
    if not creature:hasCondition(CONDITION_HASTE, 1) then
        creature:addCondition(haste) -- Apply haste condition to the player
        if debuggingEnabled then
            print("Haste applied to player at position:", position)
        end
    else
        if debuggingEnabled then
            print("Player already has haste condition at position:", position)
        end
    end

   
end
