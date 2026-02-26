

local config = {
	requiredLevel = 100,
	daily = true,
	centerDemonRoomPosition = Position(31746, 32193, 13),
	playerPositions = {
		Position(31750, 32205, 13),
		Position(31749, 32205, 13),
		Position(31748, 32205, 13),
		Position(31747, 32205, 13)
	},
	newPositions = {
		Position(31747, 32193, 13),
		Position(31746, 32193, 13),
		Position(31745, 32193, 13),
		Position(31744, 32193, 13)
	},
	demonPositions = {
		Position(31744, 32191, 13),
		Position(31746, 32191, 13),
		Position(31747, 32195, 13),
		Position(31745, 32195, 13),
		Position(31748, 32193, 13),
		Position(31749, 32193, 13)
	}
}


function onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if item.itemid == 1946 then
		local storePlayers, playerTile = {}

		for i = 1, #config.playerPositions do
			playerTile = Tile(config.playerPositions[i]):getTopCreature()
			

			if playerTile:getLevel() < config.requiredLevel then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, "All the players need to be level ".. config.requiredLevel .." or higher.")
				return true
			end

			storePlayers[#storePlayers + 1] = playerTile
		end

		local specs, spec = Game.getSpectators(config.centerDemonRoomPosition, false, false, 3, 3, 2, 2)
		for i = 1, #specs do
			spec = specs[i]
			if spec:isPlayer() then
				player:sendTextMessage(MESSAGE_STATUS_SMALL, "A team is already inside the quest room.")
				return true
			end

			spec:remove()
		end

		for i = 1, #config.demonPositions do
			Game.createMonster("Demon", config.demonPositions[i])
		end

		local players
		for i = 1, #storePlayers do
			players = storePlayers[i]
			config.playerPositions[i]:sendMagicEffect(CONST_ME_POFF)
			players:teleportTo(config.newPositions[i])
			config.newPositions[i]:sendMagicEffect(CONST_ME_TELEPORT)
			players:setDirection(DIRECTION_EAST)
		end
	elseif item.itemid == 1945 then
		item:transform(1946)
	end

	item:transform(item.itemid == 1946 and 1945 or 1946)
	return true
end
