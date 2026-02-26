local Places = {
    { name = "Dragon Mountain", experience = 100, message = "You discovered Dragon Mountain!", position = Position(4862, 3547, 7), radius = { x = 100, y = 100, z = 3 }},
    { name = "Emerald Town", experience = 1500, message = "You discovered Emerald Town!", position = Position(4793, 3447, 7), radius = { x = 100, y = 100, z = 3 }},
    -- Add more places as needed
}

local function isPlayerInPlace(playerPosition, place)
    local playerX, playerY, playerZ = playerPosition.x, playerPosition.y, playerPosition.z
    local placeX, placeY, placeZ = place.position.x, place.position.y, place.position.z
    local radius = place.radius

    -- Check if player's position is within the specified radius for x, y, and z
    local inXRange = math.abs(playerX - placeX) <= radius.x
    local inYRange = math.abs(playerY - placeY) <= radius.y
    local inZRange = math.abs(playerZ - placeZ) <= radius.z

    return inXRange and inYRange and inZRange
end

function onStepIn(player, newPos, oldPos)
    local playerPosition = newPos
	print("hello")

    -- Check if player is in any of the defined places
    for _, place in ipairs(Places) do
        if isPlayerInPlace(playerPosition, place) then
            if not player:hasDiscoveredPlace(place.name) then
                player:sendTextMessage(MESSAGE_EVENT_ADVANCE, place.message)
                player:addExperience(place.experience,true)
                player:setDiscoveredPlace(place.name, true)
            end
        end
    end
end