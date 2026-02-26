-- Enable/disable debugging
local enableDebugging = true

-- Define the Wave Spawning logic and initial variables
local waveIndex = 1
local waveData = {
    {monsters = {"minotaur guard", "minotaur", "minotaur mage", "minotaur archer"}, count = 14},
    {monsters = {"Cyclops", "Stalker", "Hunter", "Assassin", "Witch", "Beholder"}, count = 7},
    {monsters = {"Demon Skeleton", "Necromancer", "Priestess", "Vampire", "Elephant"}, count = 4},
    {monsters = {"rabbit"}, count = 1}
}

-- Define the delay between waves (in seconds)
local waveDelay = 5

-- Define a variable to track if the arena is active
local arenaActive = false

-- Define the function to spawn the next wave of monsters
local function spawnWave(index)
    if enableDebugging then
        print("Spawning wave #" .. index)
    end
    local wave = waveData[index]
    if wave then
        local arenaCenter = Position(4905, 3606, 5)
        local radius = 5  -- Adjust the radius as needed
        for i = 1, wave.count do
            local randomX = math.random(-radius, radius)
            local randomY = math.random(-radius, radius)
            local spawnPosition = Position(arenaCenter.x + randomX, arenaCenter.y + randomY, arenaCenter.z)
            local monster = Game.createMonster(wave.monsters[math.random(#wave.monsters)], spawnPosition, true)
            if monster then
                monster:setIdle(idle)
                if enableDebugging then
                    print("Spawned monster: " .. monster:getName() .. " at position (" .. spawnPosition.x .. ", " .. spawnPosition.y .. ", " .. spawnPosition.z .. ")")
                end
            end
        end
        broadcastMessage("Next wave has arrived!", MESSAGE_EVENT_ADVANCE)
        if enableDebugging then
            print("Wave " .. index .. " finished spawning.")
        end
        -- Increment wave index for the next wave
        waveIndex = waveIndex + 1
        if index == 4 then
            -- Teleport all players to level 4 center after wave 4
            local spectators = Game.getSpectators(Position(4899, 3601, 5), false, true, 45, 45)
            if #spectators > 0 then
                for _, spectator in ipairs(spectators) do
                    if spectator:getPosition().z == 5 then
                        if enableDebugging then
                            print("Teleporting player " .. spectator:getName() .. " to level 4 center.")
                        end
                        spectator:teleportTo(Position(4905, 3606, 4))
                        --startWave(spectator:getId()) -- Start the next wave for the teleported player
                    end
                end
            end
        end
    end
end

-- Define function to stop the arena and reset variables
local function stopArena()
    arenaActive = false
    waveIndex = 1
end

-- Define function to start and update the countdown timer for the wave
local function startWaveTimer(player_id)
    local player = Player(player_id)
    if not player then
        if enableDebugging then
            print("Player not found with ID: " .. player_id)
        end
        stopArena() -- Stop the arena if the player is not found
        return
    end

    local centerPosition = Position(4905, 3606, 5)
    local color = TEXTCOLOR_GREEN
    local currentWaveIndex = waveIndex  -- Store current wave index to check after timer ends

    local function updateTimer(seconds)
        if seconds > 0 then
            player:say("Next wave in: " .. seconds .. " seconds", TALKTYPE_MONSTER_SAY, false, nil, centerPosition, color)
            if enableDebugging then
                print("Timer updated. Seconds left: " .. seconds)
            end
            addEvent(updateTimer, 1000, seconds - 1)
        else
            if currentWaveIndex <= #waveData then
                spawnWave(currentWaveIndex)  -- Start the next wave if available
                if enableDebugging then
                    print("Wave spawned.")
                end
                startWaveTimer(player_id)  -- Start timer for the next wave
            else
                stopArena() -- Stop the arena if all waves have been completed
            end
        end
    end

    -- Start the timer
    updateTimer(waveDelay)
end

-- onUse event
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if enableDebugging then
        print("onUse event triggered.")
    end

    -- Check if the player is standing on the correct position to trigger the wave
    local leverPosition = Position(4903, 3604, 6)
    if player:getPosition() ~= leverPosition then
        player:sendCancelMessage("You must be standing on the lever position to trigger the wave.")
        return true
    end

    -- Check if there are enough players on all teleportation positions
    local teleportPositions = {
        Position(4905, 3604, 6),
        Position(4907, 3604, 6),
        Position(4909, 3604, 6)
    }
    for _, position in ipairs(teleportPositions) do
        local spectators = Game.getSpectators(position, false, true, 1, 1)
        if #spectators == 0 then
            player:sendCancelMessage("Not enough players on all positions to start the wave.")
            return true
        end
    end

    -- Check if the player has already completed the quest
    if player:getStorageValue(9177) ~= -1 then
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "You have already completed this quest.")
        return true
    end

    -- Set arena to active
    arenaActive = true

    -- Start the first wave
    startWaveTimer(player:getId())
    if enableDebugging then
        print("Wave started. Timer and wave spawning events scheduled.")
    end

    -- Teleport players to designated positions
    for _, position in ipairs(teleportPositions) do
        local x, y, z = position.x, position.y, position.z
        player:teleportTo(Position(x, y, z))
        if enableDebugging then
            print("Player " .. player:getName() .. " teleported to position: " .. x .. ", " .. y .. ", " .. z)
        end
    end

    -- Remove all creatures from the arena (optional, if needed)
    -- [Code for removing creatures]

end