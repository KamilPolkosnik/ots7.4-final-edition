function onStepIn(creature, item, position, fromPosition)
    if creature:getStorageValue(12001) == 1 then
        -- Check if there is item id 3599 on Position(1160, 1051, 7)
        local tile = Tile(Position(1160, 1051, 7))
        local itemOnTile = tile:getItemById(3599)
        if itemOnTile then
            creature:say("There is a paddle. I should try using it on water.", TALKTYPE_MONSTER_SAY)
        else
            creature:say("Oh, a boat. If only I had a paddle.", TALKTYPE_MONSTER_SAY)
        end
    end
    position:sendMagicEffect(14) -- Send magic effect number 14 at the specified position
end
