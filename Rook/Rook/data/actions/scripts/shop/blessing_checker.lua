local blessingNames = {
	[1] = "Spiritual Shielding",
	[2] = "Spark of the Phoenix",
	[3] = "Embrace of Tibia",
	[4] = "Fire of the Suns",
	[5] = "Wisdom of Solitude"
}

function onUse(cid, item, fromPosition, itemEx, toPosition)
	local player = Player(cid)
	if not player then
		return true
	end

	local owned = 0
	local details = {}
	for i = 1, 5 do
		local hasBless = player:hasBlessing(i)
		if hasBless then
			owned = owned + 1
		end
		details[#details + 1] = blessingNames[i] .. ": " .. (hasBless and "yes" or "no")
	end

	local summary = "Blessings: " .. owned .. "/5. " .. table.concat(details, " | ")
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, summary)
	doSendMagicEffect(player:getPosition(), CONST_ME_MAGIC_BLUE)
	return true
end
