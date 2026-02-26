-- Define a global variable to store the last activation time of the arena
local lastArenaActivationTime = 0

-- Define a function to remove Necropharus from the arena
local function removeNecropharusFromArena()
      local arenaCenterFrom = Position(32364, 32192, 9)
		local arenaCenterTo = Position(32374, 32204, 9)
		local creaturesRemoved = false
		local fromX, fromY = arenaCenterFrom.x, arenaCenterFrom.y
		local toX, toY = arenaCenterTo.x, arenaCenterTo.y

		for x = fromX, toX do
			for y = fromY, toY do
				local tile = Tile(Position(x, y, 9)) -- Adjusted to floor 9
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

end


-- Function to send magic effect and display message
local function sendMagicEffectAndMessage(pos)
    for i = 1, 3 do
        addEvent(function()
            pos:sendMagicEffect(45)
        end, (i - 1) * 500) -- Send the magic effect every 500ms for a total of 3 times
    end
end



-- Define the exit teleport event
local exitNecropharus = MoveEvent()

function exitNecropharus.onStepIn(player, item, position, fromPosition)
    local exitPos = Position(32371, 32191, 8)
    
    -- Teleport the player out of the arena
    player:teleportTo(exitPos)
    player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "As you step into the pulsating wall of energy, magic swiftly whisks you away from the vicinity.")
    
    -- Reset the arena timer
    lastArenaActivationTime = os.time()
    
    -- Remove Necropharus from the arena
    removeNecropharusFromArena()
    
    return true
end

-- Register the exit teleport event
exitNecropharus:aid(8889)
exitNecropharus:type("stepin")
exitNecropharus:register()

-- Define the enter arena event
local enterNecropharus = MoveEvent()

function enterNecropharus.onStepIn(player, item, position, fromPosition)
    local enterPos = Position(32369, 32196, 9)
    local arenaCooldown = 10 * 60 -- 10 minutes in seconds
    local arenaCenterFrom = Position(32364, 32192, 9)
    local arenaCenterTo = Position(32374, 32204, 9)

    local arenaTimeout = 10 * 60 -- 10 minutes in seconds
    local bossPosition = Position(32371, 32200, 9)
    local occupiedTeleportPos = Position(32368, 32197, 8) -- Teleport out position if arena is occupied
    local timeoutTeleportPos = Position(32369, 32197, 8) -- Teleport out position if player times out
    local blockedTeleportPos = Position(32366, 32198, 8) -- Teleport out position if arena is blocked

    -- Get the current time
    local currentTime = os.time()

    -- Check if there are any players or Necropharus in the arena
    local anyPlayersInArena = false
    local necropharusInArena = false

    for _, spectator in ipairs(Game.getSpectators(bossPosition, false, true, 6, 6)) do
        if spectator:isPlayer() then
            anyPlayersInArena = true
        elseif spectator:getName() == "Necropharus" then
            necropharusInArena = true
        end
    end

    -- Skip the cooldown timer if there are no players or Necropharus in the arena
    if not anyPlayersInArena and not necropharusInArena then
        lastArenaActivationTime = currentTime -- Update the last activation time
    else
        -- Check if enough time has passed since last arena activation
        if currentTime - lastArenaActivationTime < arenaCooldown then
            -- Player can't enter, teleport them out and display a message
            player:teleportTo(blockedTeleportPos)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The magic force is protecting this area. Come back later.")
            return false
        end
    end

    -- Set last activation time to the current time
    lastArenaActivationTime = currentTime

    -- Teleport any remaining players out of the arena
    local spectators = Game.getSpectators(arenaCenterFrom, false, true, 12, 12)
    if #spectators > 0 then
        for _, spectator in ipairs(spectators) do
            if spectator:getPosition().z == arenaCenterFrom.z then
                spectator:teleportTo(arenaCenterTo)
            end
        end
    end

    -- Check if another player is already inside the arena
    local arenaOccupied = false
    for _, spectator in ipairs(Game.getSpectators(bossPosition, false, true, 6, 6)) do
        if spectator:isPlayer() then
            arenaOccupied = true
            break
        end
    end

    if arenaOccupied then
        -- If the arena is occupied, teleport the new player to the specified position
        player:teleportTo(occupiedTeleportPos)
        player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "The arena is currently occupied. You have been teleported out.")
        return false
    end


		-- Send magic effect on each tile from (32369, 32189, 9) to (32375, 32191, 9)
	for x = 32369, 32375 do
		for y = 32189, 32191 do
			local pos = Position(x, y, 9)
			for i = 1, 3 do
				addEvent(function()
					pos:sendMagicEffect(45)
				end, (i - 1) * 500) -- Send the magic effect every 500ms for a total of 3 times
			end
		end
	end

    -- Teleport the new player to the arena position
	local enterarenapos = Position(32370, 32193, 9)
    player:teleportTo(enterarenapos)
	local textpos = Position(32371, 32190, 9)
	
	player:say("*Thump*", TALKTYPE_MONSTER_SAY, false, nil, textpos, color)
	
	
	
	-- Send magic effect on each tile from (32369, 32189, 9) to (32375, 32191, 9)
	for x = 32369, 32375 do
		for y = 32189, 32191 do
			sendMagicEffectAndMessage(Position(x, y, 9))
		end
	end

	-- Send magic effect on each tile from (32375, 32186, 9) to (32378, 32196, 9)
	for x = 32375, 32378 do
		for y = 32186, 32196 do
			sendMagicEffectAndMessage(Position(x, y, 9))
		end
	end

	-- Define a table of noises
	local noises = {"*clank*", "*bonk*", "*crash*", "*rumble*", "*pound*"}

	-- Define the range of tiles
	local minX, maxX = 32369, 32378
	local minY, maxY = 32189, 32193

	-- Define the number of random tiles you want to affect
	local numRandomTiles = 10

	-- Iterate over the random tiles
	for i = 1, numRandomTiles do
		-- Generate random coordinates within the specified range
		local randomX = math.random(minX, maxX)
		local randomY = math.random(minY, maxY)
	 
		-- Get a random noise from the table
		local randomNoise = noises[math.random(1, #noises)]
		
		-- Display the random noise on the random position
		local randomPosition = Position(randomX, randomY, 9)
		player:say(randomNoise, TALKTYPE_MONSTER_SAY, false, nil, randomPosition)
	end
		
    -- Spawn Necropharus boss in the arena with the player
    Game.createMonster("Necropharus", bossPosition)

    -- Set up a timer for arena timeout
    local timeoutEvent
    timeoutEvent = addEvent(function()
        -- Check if the player is still in the arena
        if player:getPosition() == bossPosition then
            -- Teleport the player out of the arena
            player:teleportTo(timeoutTeleportPos)
            player:sendTextMessage(MESSAGE_EVENT_ADVANCE, "Time's up! You were teleported out of the arena.")
        end
        -- Remove the timeout event
        stopEvent(timeoutEvent)
    end, arenaTimeout * 1000)

    return true
end

-- Register the enter arena event
enterNecropharus:aid(8888)
enterNecropharus:type("stepin")
enterNecropharus:register()
