-- Define the position of the chest
local chestPosition = Position(32128, 32184, 4)

-- Define the variable to track lever activation time
local leverActivationTime = 0
-- Define the exhaustion duration (in seconds)
local leverExhaustionDuration = 5 * 60 -- 5 minutes
-- Define your random rewards table
local randomRewards = {
    {itemId = 2160, count = 100}, -- Gold Coin
    {itemId = 7588, count = 1},   -- Magic Sword
    --{itemId = 2260, subtype = 4}, -- Great Health Potion
    --{itemId = 2314, subtype = 3}, -- Lightning Rune with 10 charges
    -- Add more items as needed
}

-- Function to populate the chest with random rewards
local function populateChest()
    local chest = Tile(chestPosition):getTopTopItem()
    if not chest then
        print("Error: Chest not found at position " .. chestPosition.x .. ", " .. chestPosition.y .. ", " .. chestPosition.z)
        return
    end

    for _, reward in ipairs(randomRewards) do
        local itemId = reward.itemId
        local count = reward.count or 1
        local subtype = reward.subtype or -1

        if subtype ~= -1 then
            -- Item with subtype
            chest:addItem(itemId, count, subtype)
        else
            -- Regular item or rune
            chest:addItem(itemId, count)
        end
    end
end


-- Enable/disable debugging
local enableDebugging = true

-- Define the Wave Spawning logic and initial variables
local waveIndex = 1
local waveData = {
    {monsters = {"minotaur guard", "minotaur", "minotaur mage", "minotaur archer"}, count = 18},
    {monsters = {"Cyclops", "Stalker", "Hunter", "Assassin", "Witch", "Beholder"}, count = 15},
    {monsters = {"Demon Skeleton", "Necromancer", "Priestess", "Vampire", "Mummy", "Elder Beholder"}, count = 8},
    {monsters = {"rabbit"}, count = 1}
}

-- Define the delay between waves (in seconds)
local waveDelay = 60

-- Define a variable to track if the arena is active
local arenaActive = false

-- Define function to spawn the next wave of monsters
local function spawnWave(index)
    if enableDebugging then
        print("Spawning wave #" .. index)
    end
    local wave = waveData[index]
    if wave then
        local arenaCenter = Position(32122, 32186, 5)
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
        --broadcastMessage("Next wave has arrived!", MESSAGE_EVENT_ADVANCE)
        if enableDebugging then
            print("Wave " .. index .. " finished spawning.")
        end
        -- Increment wave index for the next wave
        waveIndex = waveIndex + 1
        if index == 4 then
            --spawnRandomItem()
            -- Teleport all players to level 4 center after wave 4
            local spectators = Game.getSpectators(Position(32122, 32186, 5), false, true, 45, 45)
            if #spectators > 0 then
                for _, spectator in ipairs(spectators) do
                    if spectator:getPosition().z == 5 then
                        if enableDebugging then
                            print("Teleporting player " .. spectator:getName() .. " to level 4 center and setting storage 9177 to 1.")
                        end
                        spectator:addExperience(math.random(1000,5000),true)
                        spectator:getPosition():sendMagicEffect(28)
                        spectator:addMoney(math.random(1500,3000))
                        spectator:teleportTo(Position(32123, 32187, 4))
                        spectator:setStorageValue(9177, 1)  -- Update storage value to 1
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
local function startWaveTimer(tile)
    local centerPosition = tile
    local color = TEXTCOLOR_GREEN
    local currentWaveIndex = waveIndex  -- Store current wave index to check after timer ends

    local function updateTimer(seconds)
        if seconds > 0 then
            for _, player in ipairs(Game.getSpectators(centerPosition, false, true, 65, 65)) do
                if player:isPlayer() then
                    player:say("Next wave in: " .. seconds .. " seconds", TALKTYPE_MONSTER_SAY, false, nil, centerPosition, color)
                end
            end
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
                startWaveTimer(centerPosition)  -- Start timer for the next wave
            else
                stopArena() -- Stop the arena if all waves have been completed
            end
        end
    end

    -- Start the timer
    updateTimer(waveDelay)
end

-- Define a boolean variable to enable/disable the requirement for players on teleportation positions
local requirePlayersOnTeleportation = false

-- Define the lever position
local leverPosition = Position(32120, 32184, 6)

-- Define teleport positions
local teleportPositions = {
    leverPosition, -- Lever position added
    Position(32122, 32184, 6),
    Position(32124, 32184, 6),
    Position(32126, 32184, 6)
}

-- Define the exhaustion storage value and duration (in seconds)
local exhaustionStorage = 20002
local exhaustionDuration = 15 * 60 -- 15 minutes

local questStorage = 9178
-- onUse event
function onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if enableDebugging then
        print("onUse event triggered.")
    end
	local currentTime = os.time()
    if currentTime < leverActivationTime + leverExhaustionDuration then
        player:sendCancelMessage("The lever is currently blocked. You cannot use it.")
        return true
    end
    -- Check if the player has storage value 9177
    --if player:getStorageValue(questStorage) ~= -1 then
    --  player:sendCancelMessage("Someone already finished this Tower Of Chaos.")
    --return true
    --end

    -- Check if any player is standing on a teleportation position and has storage value 9177
    local anyEligiblePlayer = false
    for _, position in ipairs(teleportPositions) do
        local spectators = Game.getSpectators(position, false, true, 1, 1)
        for _, spectator in ipairs(spectators) do
            if spectator:getStorageValue(questStorage) == -1 then
                anyEligiblePlayer = true
                break
            end
            if spectator:getStorageValue(questStorage) == 1 then
                player:sendCancelMessage(spectator:getName() .. " has already completed this quest.")
                return true
            end
        end
        if anyEligiblePlayer then
            break
        end
    end

    -- If no eligible player found, cancel the wave trigger
    if not anyEligiblePlayer then
        player:sendCancelMessage("No eligible players to start the wave.")
        return true
    end

    -- Check if the player is exhausted
    if player:getStorageValue(exhaustionStorage) > os.time() then
        player:sendCancelMessage("You are exhausted and cannot enter the arena yet.")
        return true
    end

    -- Set arena to active
    arenaActive = true
	leverActivationTime = currentTime
    -- Start the first wave
    startWaveTimer(Position(32122, 32186, 5))
    if enableDebugging then
        print("Wave started. Timer and wave spawning events scheduled.")
    end

    -- Set exhaustion storage for the player
    player:setStorageValue(exhaustionStorage, os.time() + exhaustionDuration)

    -- Remove all creatures from the arena
    local creaturesRemoved = false
    for i = 32117, 32181 do
        for j = 32128, 32192 do
            local tile = Tile(Position(i, j, 5))
            if tile then
                local creatures = tile:getCreatures()
                if creatures then
                    for _, creature in ipairs(creatures) do
                        if enableDebugging then
                            print("Removed creature: " .. creature:getName())
                        end
                        creature:remove()
                        creaturesRemoved = true
                    end
                end
            end
        end
    end

    -- Teleport players from the designated teleportation positions only if their storage value 9177 is -1
    local teleportPosition = Position(32123, 32189, 5) -- Adjust the teleport destination as needed
    for i, position in ipairs(teleportPositions) do
        local spectators = Game.getSpectators(position, false, true, 1, 1)
        for _, spectator in ipairs(spectators) do
            if spectator:getStorageValue(questStorage) == -1 then
                spectator:teleportTo(teleportPosition)
                if enableDebugging then
                    print("Player " .. spectator:getName() .. " teleported to position: " .. teleportPosition.x .. ", " .. teleportPosition.y .. ", " .. teleportPosition.z)
                end
            else
                if enableDebugging then
                    print("Player " .. spectator:getName() .. " is not teleported because their storage value 9177 is not -1.")
                end
            end
        end
    end
end
