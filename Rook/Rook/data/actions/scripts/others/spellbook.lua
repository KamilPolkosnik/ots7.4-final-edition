function onUse(cid, item, frompos, item2, topos)
	local player = Player(cid)
	if not player then
		return false
	end

	local text = ""
	local spells = {}

	for _, spell in ipairs(player:getInstantSpells()) do
		if type(spell) == "table" then
			local level = tonumber(spell.level) or 0
			local manapercent = tonumber(spell.manapercent) or 0
			local mana = spell.mana or 0
			local name = spell.name or "unknown spell"
			local words = spell.words or ""

			if manapercent > 0 then
				mana = manapercent .. "%"
			end

			-- Hide internal/monster words (#xxxx) and house utility spells.
			if level >= 0 and words ~= "" and not string.match(name, "House") and string.sub(words, 1, 1) ~= "#" then
				spells[#spells + 1] = {
					level = level,
					mana = mana,
					name = name,
					words = words
				}
			end
		end
	end

	table.sort(spells, function(a, b) return a.level < b.level end)

	local prevLevel = -1
	for i, spell in ipairs(spells) do
		local line = ""
		if prevLevel ~= spell.level then
			if i ~= 1 then
				line = "\n"
			end

			line = line .. "Spells for Magic Level " .. spell.level .. "\n"
			prevLevel = spell.level
		end

		text = text .. line .. "  " .. spell.words .. " - " .. spell.name .. " : " .. tostring(spell.mana) .. "\n"
	end

	player:showTextDialog(item.itemid, text, false)
	return true
end
