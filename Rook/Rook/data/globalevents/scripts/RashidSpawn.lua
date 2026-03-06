local rashidPositionsByWday = {
	[2] = Position(32681, 31687, 2), -- Monday (custom)
	[3] = Position(32936, 32076, 7), -- Tuesday
	[4] = Position(32363, 32205, 7), -- Wednesday
	[5] = Position(33066, 32880, 6), -- Thursday
	[6] = Position(33239, 32483, 7), -- Friday
	[7] = Position(33171, 31810, 6), -- Saturday
	[1] = Position(32335, 31782, 6), -- Sunday
}

-- true: single spawn based on weekday, false: spawn in all configured positions
local spawnByDay = true

function onStartup()
	if spawnByDay then
		local wday = os.date("*t").wday
		local position = rashidPositionsByWday[wday]
		if not position then
			return
		end

		local npc = Game.createNpc("rashid", position, false, true)
		if npc then
			npc:setMasterPos(position)
		end
	else
		for _, position in pairs(rashidPositionsByWday) do
			local npc = Game.createNpc("rashid", position, false, true)
			if npc then
				npc:setMasterPos(position)
			end
		end
	end
end
