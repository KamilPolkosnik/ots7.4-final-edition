local destinations = {
    dq = Position(33323, 31592, 15),
}

function onSay(player, words, param)
    if not player:getGroup():getAccess() then
        return true
    end

    local key = param:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if key ~= "" and destinations[key] then
        player:teleportTo(destinations[key])
        return false
    end

    local target = Creature(param)
    if target then
        player:teleportTo(target:getPosition())
    else
        player:sendCancelMessage("Creature not found.")
    end
    return false
end
