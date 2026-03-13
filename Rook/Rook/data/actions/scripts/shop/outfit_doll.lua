local STORE_OUTFITS = {
	{name = "Citizen", male = {type = 128, addons = 3}, female = {type = 136, addons = 3}},
	{name = "Hunter", male = {type = 129, addons = 3}, female = {type = 137, addons = 3}},
	{name = "Mage", male = {type = 130, addons = 3}, female = {type = 138, addons = 3}},
	{name = "Knight", male = {type = 131, addons = 3}, female = {type = 139, addons = 3}},
	{name = "Noble", male = {type = 132, addons = 3}, female = {type = 140, addons = 3}},
	{name = "Summoner", male = {type = 133, addons = 3}, female = {type = 141, addons = 3}},
	{name = "Warrior", male = {type = 134, addons = 3}, female = {type = 142, addons = 3}},
	{name = "Barbarian", male = {type = 143, addons = 3}, female = {type = 147, addons = 3}},
	{name = "Druid", male = {type = 144, addons = 3}, female = {type = 148, addons = 3}},
	{name = "Wizard", male = {type = 145, addons = 3}, female = {type = 149, addons = 3}},
	{name = "Oriental", male = {type = 146, addons = 3}, female = {type = 150, addons = 3}},
	{name = "Pirate", male = {type = 151, addons = 3}, female = {type = 155, addons = 3}},
	{name = "Assassin", male = {type = 152, addons = 3}, female = {type = 156, addons = 3}},
	{name = "Beggar", male = {type = 153, addons = 3}, female = {type = 157, addons = 3}},
	{name = "Shaman", male = {type = 154, addons = 3}, female = {type = 158, addons = 3}}
}

local function ownsOutfit(player, outfitData)
	local male = outfitData.male
	local female = outfitData.female

	if player:hasOutfit(male.type) or player:hasOutfit(female.type) then
		return true
	end

	if male.addons and male.addons > 0 then
		if player:hasOutfit(male.type, male.addons) or player:hasOutfit(female.type, female.addons) then
			return true
		end
	end

	return false
end

local function grantOutfit(player, outfitData)
	local male = outfitData.male
	local female = outfitData.female

	if male.addons and male.addons > 0 then
		player:addOutfitAddon(male.type, male.addons)
		player:addOutfitAddon(female.type, female.addons)
	else
		player:addOutfit(male.type)
		player:addOutfit(female.type)
	end
end

function onUse(cid, item, fromPosition, target, toPosition, isHotkey)
	local player = Player(cid)
	if not player then
		return true
	end

	local available = {}
	for i = 1, #STORE_OUTFITS do
		local entry = STORE_OUTFITS[i]
		if not ownsOutfit(player, entry) then
			available[#available + 1] = entry
		end
	end

	if #available == 0 then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "You already have all basic store outfits (450 points category).")
		return true
	end

	local selected = available[math.random(#available)]
	grantOutfit(player, selected)
	item:remove(1)
	doSendMagicEffect(player:getPosition(), CONST_ME_GIFT_WRAPS)
	player:sendTextMessage(MESSAGE_STATUS_CONSOLE_ORANGE, "You received random outfit: " .. selected.name .. ".")
	return true
end
