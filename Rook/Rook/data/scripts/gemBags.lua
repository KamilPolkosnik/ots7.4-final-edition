local GEM_BAG_ITEM_ID = 6512
local CHANCE_NO_ITEM = 30
local CHANCE_ONE_ITEM = 60
local CHANCE_MULTI_ITEMS = 10

-- Task rewards: Craft + Crystals categories only.
local GEM_BAG_LOOT = {
    -- Craft (creature)
    2229, 2230, 2747, 2802, 2033, 2151, 2193, 2231, 1976, 2134,
    2174, 2176, 2237, 2359, 2804, 1977, 1982, 2070, 2159, 2220,
    3955, 1967, 1986, 2074, 2110, 2194, 2245, 2348, 2349, 2354,
    2560, 2678, 2745, 2760, 2803, 3956, 6437,
    -- Crystals (craft)
    7870, 7871, 7872, 7873, 7874, 7875, 7876, 7877,
    7879, 7882, 7883, 7953
}

local function getRandomItem(items)
    return items[math.random(1, #items)]
end

local function buildRandomUniqueItems(items, amount)
    local pool = {}
    for i = 1, #items do
        pool[i] = items[i]
    end

    local selected = {}
    local maxItems = math.min(amount, #pool)
    for _ = 1, maxItems do
        local index = math.random(1, #pool)
        selected[#selected + 1] = pool[index]
        table.remove(pool, index)
    end
    return selected
end

local gemBag = Action()
gemBag:id(GEM_BAG_ITEM_ID)

function gemBag.onUse(player, item, fromPosition, target, toPosition, isHotkey)
    local roll = math.random(1, 100)
    local lootItems = {}

    if roll <= CHANCE_NO_ITEM then
        -- 30%: no reward
    elseif roll <= CHANCE_NO_ITEM + CHANCE_ONE_ITEM then
        -- 60%: exactly one random reward
        lootItems[1] = getRandomItem(GEM_BAG_LOOT)
    else
        -- 10%: exactly two random rewards
        lootItems = buildRandomUniqueItems(GEM_BAG_LOOT, 2)
    end

    item:remove(1)

    if #lootItems == 0 then
        player:say("You found nothing.", TALKTYPE_MONSTER_SAY)
        return true
    end

    local message = "You found: "
    for i = 1, #lootItems do
        local lootItemId = lootItems[i]
        player:addItem(lootItemId, 1)

        local itemType = ItemType(lootItemId)
        message = message .. itemType:getArticle() .. " " .. itemType:getName()
        if i < #lootItems then
            message = message .. ", "
        end
    end

    player:say(message, TALKTYPE_MONSTER_SAY)
    return true
end

gemBag:register()
