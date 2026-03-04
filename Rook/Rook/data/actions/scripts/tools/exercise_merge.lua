local EXERCISE_ITEM_IDS = {
	[6877] = true, -- exercise rod
	[6878] = true, -- exercise bow
	[6879] = true, -- exercise axe
	[6880] = true, -- exercise sword
	[6881] = true  -- exercise club
}

local MAX_CHARGES = 15000

local function getCharges(item)
	if not item then
		return 0
	end

	if item.type and item.type > 0 then
		return item.type
	end

	return 0
end

function onUse(cid, item, fromPosition, itemEx, toPosition, isHotkey)
	if not itemEx or itemEx.uid <= 0 then
		return false
	end

	-- Allow "use with" on creatures: set target and let normal weapon combat handle damage/speed/charges.
	if isCreature(itemEx.uid) then
		local player = Player(cid)
		local target = Creature(itemEx.uid)
		if not player or not target then
			return false
		end

		if target:getId() ~= cid then
			player:setTarget(target)
		end
		return true
	end

	if not itemEx.itemid or not EXERCISE_ITEM_IDS[item.itemid] or item.itemid ~= itemEx.itemid then
		return false
	end

	if item.uid == itemEx.uid then
		return true
	end

	local chargesA = getCharges(item)
	local chargesB = getCharges(itemEx)
	if chargesA <= 0 or chargesB <= 0 then
		return false
	end

	local total = chargesA + chargesB
	local merged = math.min(MAX_CHARGES, total)
	local overflow = total - merged

	doChangeTypeItem(item.uid, merged)

	if overflow <= 0 then
		doRemoveItem(itemEx.uid, 1)
	else
		doChangeTypeItem(itemEx.uid, overflow)
	end

	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_MAGIC_GREEN)
	doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_BLUE, "Merged charges: " .. merged .. (overflow > 0 and (" (overflow: " .. overflow .. ")") or ""))
	return true
end
