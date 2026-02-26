local leverPosition = Position(3385, 1171, 15) -- Position of the lever

function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Check if the lever is being used
    if fromPosition == leverPosition and item.itemid == 1946 then
        -- Check if the player's storage 6090 is -1
        if player:getStorageValue(6090) == -1 then
            -- Add experience to the player
            player:addExperience(1000, true) -- Adjust the experience value as needed

            -- Set storage 6090 to 1
            player:setStorageValue(6090, 1)
        end

        -- Remove the wall
        removeWall()

        -- Transform the lever
        item:transform(1946)
        return true
    end
    return false
end

function removeWall()
    -- Define the positions of the wall
    local wallPositions = {
        Position(3385, 1171, 15),
        Position(3386, 1171, 15),
        Position(3387, 1171, 15),
        Position(3388, 1171, 15),
        Position(3389, 1171, 15)
    }

    -- Iterate over the wall positions
    for _, pos in ipairs(wallPositions) do
        local tile = Tile(pos)
        local thing = tile:getItemById(1304)
        if thing then
            thing:remove()
        end
    end
end
