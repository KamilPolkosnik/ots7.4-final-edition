
-- Define other items for loot tables
local LOW_TIER_LOOT = {
    {itemID = 3976, count = math.random(1,100)},
	{itemID = 3976, count = math.random(1,100)}, 
	{itemID = 3976, count = math.random(1,100)}, 	
    {itemID = 2152, count = math.random(1,7)}, 
    2800, 
    2687,
    2799,
    2801,
    2802,
    2803,
    2804,
    2805,
    2759,
    2741,
    2760,
    2229,
    2230,
    2231,
    2219,
	7870,
	7871,
	7872,
	7873,
	7874,
	7875
}			


--7870, 7871, 7872, 7873, 7874, 7875
local MID_TIER_LOOT = {2147, 2146, 2149, 7924,1986,1985,1984,1983,1982,2798,7953,7881} 

local HIGH_TIER_LOOT = GEM_IDS 

-- Define the chances for mid-tier and high-tier loot
local MID_TIER_CHANCE = 5 
local HIGH_TIER_CHANCE = 1 

-- Define chances for finding multiple items
local TWO_ITEMS_CHANCE = 30 
local THREE_ITEMS_CHANCE = 15 

-- Function to randomly select an item from a table
local function getRandomItem(items)
    return items[math.random(1, #items)]
end

-- Register gem bag action
local gemBag = Action()
gemBag:id(6512)

function gemBag.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    -- Roll for number of items
    local rollItems = math.random(1, 100)
    local numItems = 1
    
    if rollItems <= THREE_ITEMS_CHANCE then
        numItems = 3
    elseif rollItems <= TWO_ITEMS_CHANCE + THREE_ITEMS_CHANCE then
        numItems = 2
    end

    -- Roll for loot
    local lootItems = {}
    for i = 1, numItems do
        local roll = math.random(1, 100)
        local lootItem = nil

        if roll <= HIGH_TIER_CHANCE then
            lootItem = getRandomItem(HIGH_TIER_LOOT)
        elseif roll <= MID_TIER_CHANCE then
            lootItem = getRandomItem(MID_TIER_LOOT)
        else
            local lowTierItem = getRandomItem(LOW_TIER_LOOT)
            if type(lowTierItem) == "table" then
                lootItem = lowTierItem.itemID
                player:addItem(lootItem, lowTierItem.count)
            else
                lootItem = lowTierItem
            end
        end

        -- If loot item is not found, roll for gem
        if not lootItem then
            lootItem = getRandomItem(GEM_IDS)
        end

        table.insert(lootItems, lootItem)
    end

    -- Inform the player about the result
    local message = "You found: "
    for i, lootItem in ipairs(lootItems) do
        message = message .. ItemType(lootItem):getArticle() .. " " .. ItemType(lootItem):getName()
        if i < #lootItems then
            message = message .. ", "
        end
        player:addItem(lootItem, 1)
    end

    -- Remove the gem bag from the player's inventory
    item:remove(1)

    player:say(message, TALKTYPE_MONSTER_SAY)

    return true
end

gemBag:register()