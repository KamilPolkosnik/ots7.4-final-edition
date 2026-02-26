local posToAid = dofile('data/actions/scripts/quests/tvp_pos_to_aid.lua')
local chests = dofile('data/actions/scripts/quests/tvp_chests.lua')

local function findAndSet(container, keyId, keynumber)
	for i = 0, container:getSize() - 1 do
		local it = container:getItem(i)
		if it then
			if it:getId() == keyId then
				local current = it:getAttribute(ITEM_ATTRIBUTE_KEYNUMBER)
				if not current or current == 0 then
					if ITEM_ATTRIBUTE_KEYNUMBER then
						it:setAttribute(ITEM_ATTRIBUTE_KEYNUMBER, keynumber)
					end
				end
				if it:getActionId() == 0 then
					it:setActionId(keynumber)
				end
				return true
			end
			if it:isContainer() then
				if findAndSet(it, keyId, keynumber) then
					return true
				end
			end
		end
	end
	return false
end

local function findContainerOnTile(tile)
	if not tile then
		return nil
	end
	local items = tile:getItems()
	for i = 1, tile:getItemCount() do
		local it = items[i]
		if it and it:isContainer() then
			return it
		end
	end
	return nil
end

function onStartup()
	local applied = 0
	local missing = 0

	for posKey, aid in pairs(posToAid) do
		local chest = chests[aid]
		if chest then
			local keys = {}
			if chest.item and chest.item.keynumber then
				table.insert(keys, {id = chest.item.id, keynumber = chest.item.keynumber})
			end
			if chest.content then
				for _, reward in ipairs(chest.content) do
					if reward.keynumber then
						table.insert(keys, {id = reward.id, keynumber = reward.keynumber})
					end
				end
			end

			if #keys > 0 then
				local x, y, z = posKey:match('^(%d+),(%d+),(%d+)$')
				if x then
					local tile = Tile(Position(tonumber(x), tonumber(y), tonumber(z)))
					local container = findContainerOnTile(tile)
					if not container then
						missing = missing + 1
					else
						local okAll = true
						for _, k in ipairs(keys) do
							if findAndSet(container, k.id, k.keynumber) then
								applied = applied + 1
							else
								okAll = false
							end
						end
						if not okAll then
							missing = missing + 1
						end
					end
				end
			end
		end
	end

	print(string.format('[QuestKeynumberFixups] applied=%d missing=%d', applied, missing))
	return true
end
