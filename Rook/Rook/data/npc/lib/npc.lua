-- Including the Advanced NPC System
dofile('data/npc/lib/npcsystem/npcsystem.lua')

local function getTierRangeForNpcItem(tier)
	tier = tonumber(tier)
	if not tier then
		return nil
	end
	tier = math.floor(tier)

	local cfg = rawget(_G, "US_CONFIG")
	if type(cfg) ~= "table" then
		return nil
	end

	local minTier = math.max(1, math.floor(tonumber(cfg.ITEM_TIER_MIN) or 1))
	local maxTier = math.max(minTier, math.floor(tonumber(cfg.ITEM_TIER_MAX) or 25))
	if tier < minTier or tier > maxTier then
		return nil
	end

	local customTiers = cfg.ITEM_LEVEL_TIERS
	if type(customTiers) == "table" and type(customTiers[tier]) == "table" then
		local customMin = tonumber(customTiers[tier].min)
		local customMax = tonumber(customTiers[tier].max)
		if customMin and customMax then
			customMin = math.max(1, math.floor(customMin))
			customMax = math.max(customMin, math.floor(customMax))
			return customMin, customMax
		end
	end

	local levelStep = math.max(1, math.floor(tonumber(cfg.ITEM_LEVEL_PER_TIER) or 25))
	local firstTierMin = math.max(1, math.floor(tonumber(cfg.ITEM_LEVEL_FIRST_TIER_MIN) or 1))
	local minLevel = (tier == minTier) and firstTierMin or ((tier - 1) * levelStep)
	local maxLevel = tier * levelStep
	minLevel = math.max(1, minLevel)
	maxLevel = math.max(minLevel, maxLevel)
	return minLevel, maxLevel
end

local function ensureNpcShopItemLevel(item)
	if not item or not item.isItem or not item:isItem() then
		return
	end

	local itemType = item:getType()
	local canHaveItemLevel = item.getItemLevel and item.setItemLevel
	if itemType and itemType.canHaveItemLevel then
		local ok, result = pcall(function()
			return itemType:canHaveItemLevel()
		end)
		if ok then
			canHaveItemLevel = canHaveItemLevel and result
		end
	end

	if not canHaveItemLevel then
		return
	end

	-- Prefer normal UpgradeSystem tier roll; fallback to level 1 when the item still has no Item Level.
	if item.getItemLevel and item:getItemLevel() <= 0 then
		if item.ensureInitialTierLevel then
			item:ensureInitialTierLevel(false)
		end

		if item.getItemLevel and item.setItemLevel and item:getItemLevel() <= 0 and item.getItemTier then
			local tier = item:getItemTier()
			local minLevel, maxLevel = getTierRangeForNpcItem(tier)
			if minLevel and maxLevel then
				item:setItemLevel(math.random(minLevel, maxLevel), false)
			end
		end

		if item.getItemLevel and item:setItemLevel and item:getItemLevel() <= 0 then
			item:setItemLevel(1, false)
		end
	end
end

function msgcontains(message, keyword)
	local message, keyword = message:lower(), keyword:lower()
	if message == keyword then
		return true
	end

	return message:find(keyword) and not message:find('(%w+)' .. keyword)
end

function doNpcSellItem(cid, itemid, amount, subType, ignoreCap, inBackpacks, backpack)
	local amount = amount or 1
	local subType = subType or 0
	local item = 0
	if ItemType(itemid):isStackable() then
		if inBackpacks then
			stuff = Game.createItem(backpack, 1)
			item = stuff:addItem(itemid, math.min(100, amount))
			ensureNpcShopItemLevel(item)
		else
			stuff = Game.createItem(itemid, math.min(100, amount))
			ensureNpcShopItemLevel(stuff)
		end
		return Player(cid):addItemEx(stuff, ignoreCap) ~= RETURNVALUE_NOERROR and 0 or amount, 0
	end

	local a = 0
	if inBackpacks then
		local container, b = Game.createItem(backpack, 1), 1
		for i = 1, amount do
			local item = container:addItem(itemid, subType)
			ensureNpcShopItemLevel(item)
			if table.contains({(ItemType(backpack):getCapacity() * b), amount}, i) then
				if Player(cid):addItemEx(container, ignoreCap) ~= RETURNVALUE_NOERROR then
					b = b - 1
					break
				end

				a = i
				if amount > i then
					container = Game.createItem(backpack, 1)
					b = b + 1
				end
			end
		end
		return a, b
	end

	for i = 1, amount do -- normal method for non-stackable items
		local item = Game.createItem(itemid, subType)
		ensureNpcShopItemLevel(item)
		if Player(cid):addItemEx(item, ignoreCap) ~= RETURNVALUE_NOERROR then
			break
		end
		a = i
	end
	return a, 0
end

local func = function(cid, text, type, e, pcid)
	if Player(pcid):isPlayer() then
		local creature = Creature(cid)
		creature:say(text, type, false, pcid, creature:getPosition())
		e.done = true
	end
end

function doCreatureSayWithDelay(cid, text, type, delay, e, pcid)
	if Player(pcid):isPlayer() then
		e.done = false
		e.event = addEvent(func, delay < 1 and 1000 or delay, cid, text, type, e, pcid)
	end
end

function doPlayerSellItem(cid, itemid, count, cost)
	local player = Player(cid)
	if player:removeItem(itemid, count) then
		if not player:addMoney(cost) then
			error('Could not add money to ' .. player:getName() .. '(' .. cost .. 'gp)')
		end
		return true
	end
	return false
end

function doPlayerBuyItemContainer(cid, containerid, itemid, count, cost, charges)
	local player = Player(cid)
	if not player:removeTotalMoney(cost) then
		return false
	end

	for i = 1, count do
		local container = Game.createItem(containerid, 1)
		for x = 1, ItemType(containerid):getCapacity() do
			local item = container:addItem(itemid, charges)
			ensureNpcShopItemLevel(item)
		end

		if player:addItemEx(container, true) ~= RETURNVALUE_NOERROR then
			return false
		end
	end
	return true
end

function getCount(string)
	local b, e = string:find("%d+")
	local tonumber = tonumber(string:sub(b, e))
	if tonumber > 2 ^ 32 - 1 then
		print("Warning: Casting value to 32bit to prevent crash\n"..debug.traceback())
	end
	return b and e and math.min(2 ^ 32 - 1, tonumber) or -1
end

function Player.getTotalMoney(self)
	return self:getMoney() + self:getBankBalance()
end

function isValidMoney(money)
	return isNumber(money) and money > 0
end

function getMoneyCount(string)
	local b, e = string:find("%d+")
	local tonumber = tonumber(string:sub(b, e))
	if tonumber > 2 ^ 32 - 1 then
		print("Warning: Casting value to 32bit to prevent crash\n"..debug.traceback())
	end
	local money = b and e and math.min(2 ^ 32 - 1, tonumber) or -1
	if isValidMoney(money) then
		return money
	end
	return -1
end

function getMoneyWeight(money)
	local gold = money
	local crystal = math.floor(gold / 10000)
	gold = gold - crystal * 10000
	local platinum = math.floor(gold / 100)
	gold = gold - platinum * 100
	return (ItemType(ITEM_CRYSTAL_COIN):getWeight() * crystal) + (ItemType(ITEM_PLATINUM_COIN):getWeight() * platinum) + (ItemType(ITEM_GOLD_COIN):getWeight() * gold)
end
