local blessingNames = {
	[1] = "Spiritual Shielding",
	[2] = "Spark of the Phoenix",
	[3] = "Embrace of Tibia",
	[4] = "Fire of the Suns",
	[5] = "Wisdom of Solitude"
}

function onSay(player, words, param)
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
	return false
end

