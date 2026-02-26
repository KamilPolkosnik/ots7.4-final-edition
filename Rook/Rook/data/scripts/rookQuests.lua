local rookQuest1storage = 7041
local rookQuest1 = Action()
function rookQuest1.onUse(player, item, fromPosition, target, toPosition, isHotkey)

	 if player:getStorageValue(rookQuest1storage) ~= 1 then
		player:say("Smells like honey.", TALKTYPE_MONSTER_SAY)
		player:setStorageValue(rookQuest1storage, 1)
		player:addItem(2103)
	else
		player:say("This is empty", TALKTYPE_MONSTER_SAY)
	end
end

rookQuest1:aid(7041)
rookQuest1:register()


-- Creating rookQuest2 -- KEY katana
local rookQuest2storage = 7042
local rookQuest2 = Action()

function rookQuest2.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(rookQuest2storage) ~= 1 then
		player:say("This body stinks, but I found this key!", TALKTYPE_MONSTER_SAY)
		player:setStorageValue(rookQuest2storage, 1)
		
		local silverKey = player:addItem(2088) -- Silver Key item ID
		
		silverKey:setActionId(2007)
	else
		player:say("This is empty", TALKTYPE_MONSTER_SAY)
	end
end

rookQuest2:aid(7018)
rookQuest2:register()


-- DOublet

-- Creating rookQuest3
local rookQuest3storage = 7043
local rookQuest3 = Action()

function rookQuest3.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(rookQuest3storage) ~= 1 then
		player:say("Neat! A doublet!", TALKTYPE_MONSTER_SAY)
		player:setStorageValue(rookQuest3storage, 1)
		player:addItem(2485) -- Doublet item ID
	else
		-- If the quest has already been completed, you can add code here for any actions you want to perform.
	end
end

rookQuest3:aid(7014)
rookQuest3:register()


local rookQuest4 = Action()

function rookQuest4.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	player:say("Just a stinky dead body.", TALKTYPE_MONSTER_SAY) -- Empty message
end

rookQuest4:aid(999)
rookQuest4:register()



local rookQuest5storage = 7031
local rookQuest5 = Action()

function rookQuest5.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(rookQuest5storage) ~= 1 then
        player:say("I found a banana!", TALKTYPE_MONSTER_SAY)
        player:addItem(2676, 1) -- Banana item ID
        player:setStorageValue(rookQuest5storage, 1)
    end
end

rookQuest5:aid(rookQuest5storage)
rookQuest5:register()


-- Creating rookQuest6
local rookQuest6storage = 7039
local rookQuest6 = Action()

function rookQuest6.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if player:getStorageValue(rookQuest6storage) ~= 1 then
        player:say("This is the body of Ferumbras.", TALKTYPE_MONSTER_SAY)
        player:setStorageValue(rookQuest6storage, 1)
    end
end

rookQuest6:aid(7039)
rookQuest6:register()


-- Creating rookQuest2 -- KEY katana
local rookQuest7storage = 7060
local rookQuest7 = Action()

function rookQuest7.onUse(player, item, fromPosition, target, toPosition, isHotkey)
	if player:getStorageValue(rookQuest7storage) ~= 1 then
		player:say("There was a key in this grave!", TALKTYPE_MONSTER_SAY)
		player:setStorageValue(rookQuest7storage, 1)
		
		local silverKey = player:addItem(2088) -- Silver Key item ID
		
		silverKey:setActionId(2015)
	else
		player:say("This is empty", TALKTYPE_MONSTER_SAY)
	end
end

rookQuest7:aid(7060)
rookQuest7:register()




local rookQuest8storage = 888
local rookQuest8counter = 0
local rookQuest8 = Action()

function rookQuest8.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    if rookQuest8counter > 5 then
        player:say("There is nothing in the barrels.", TALKTYPE_MONSTER_SAY)
    else
        if player:getStorageValue(rookQuest8storage) < 5 then
            player:say("You found some gold coins!", TALKTYPE_MONSTER_SAY)
            local goldAmount = math.random(1, 100)
            player:addItem(2148, goldAmount)
            player:setStorageValue(rookQuest8storage, player:getStorageValue(rookQuest8storage) + 1)
        else -- <=
            player:say("You found a tapestry!", TALKTYPE_MONSTER_SAY)
            local tapestryItems = {1857, 1860, 1863, 1866, 1869, 1872, 1880}
            local randomTapestry = tapestryItems[math.random(1, #tapestryItems)]
            player:addItem(randomTapestry, 1)
        end
    end
    rookQuest8counter = rookQuest8counter + 1
    return true
end

rookQuest8:aid(888)
rookQuest8:register()