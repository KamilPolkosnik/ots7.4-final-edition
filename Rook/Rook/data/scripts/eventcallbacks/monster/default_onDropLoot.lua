local ec = EventCallback

local function getVariantLootRolls(monster)
    if not MonsterVariants then
        return 1
    end

    local tiers = MonsterVariants.tiers
    if not tiers then
        return 1
    end

    local skull = monster:getSkull()
    if skull == SKULL_GREEN and tiers[1] and tiers[1].lootRolls then
        return tiers[1].lootRolls
    elseif skull == SKULL_YELLOW and tiers[2] and tiers[2].lootRolls then
        return tiers[2].lootRolls
    elseif skull == SKULL_RED and tiers[3] and tiers[3].lootRolls then
        return tiers[3].lootRolls
    end
    return 1
end

local function isEquipmentItem(item)
    local it = item:getType()
    if it:isContainer() then
        return false
    end
    if it:isWeapon() or it:isShield() or it:isBow() or it:isWand() then
        return true
    end
    if it:isHelmet() or it:isArmor() or it:isLegs() or it:isBoots() then
        return true
    end
    if it:isNecklace() or it:isRing() or it:isAmmo() or it:isTrinket() then
        return true
    end
    return false
end

local function moveEquipmentIntoBag(corpse)
    local items = corpse:getItems(true)
    if not items then
        return
    end

    local equipment = {}
    local bag = nil

    for _, item in ipairs(items) do
        if item:getId() == 1987 and item:isContainer() then
            if not bag then
                bag = item
            end
        elseif isEquipmentItem(item) then
            equipment[#equipment + 1] = item
        end
    end

    if #equipment == 0 then
        if bag and bag:getSize() == 0 then
            bag:remove()
        end
        return
    end

    if not bag then
        bag = corpse:addItem(1987, 1)
    end
    if not bag then
        return
    end

    for _, item in ipairs(equipment) do
        local parent = item:getParent()
        if parent == corpse then
            item:moveTo(bag)
        end
    end

    if bag:getSize() == 0 then
        bag:remove()
    end
end

ec.onDropLoot = function(self, corpse)
    if configManager.getNumber(configKeys.RATE_LOOT) == 0 then
        return
    end

    local player = Player(corpse:getCorpseOwner())
    local mType = self:getType()
    if not player or player:getStamina() > 840 then
        local rolls = getVariantLootRolls(self)
        local monsterLoot = mType:getLoot()
        for _ = 1, rolls do
            for i = 1, #monsterLoot do
                local item = corpse:createLootItem(monsterLoot[i])
                if not item then
                    print('[Warning] DropLoot:', 'Could not add loot item to corpse.')
                end
            end
        end

        -- Bagging moved to UpgradeSystem us_CheckCorpse so rarity rolls happen first.

        if player then
            local text = ("Loot of %s: %s"):format(mType:getNameDescription(), corpse:getContentDescription())
            local party = player:getParty()
            if party then
                party:broadcastPartyLoot(text)
            else
                player:sendTextMessage(MESSAGE_INFO_DESCR, text)
            end
        end
    else
        local text = ("Loot of %s: nothing (due to low stamina)"):format(mType:getNameDescription())
        local party = player:getParty()
        if party then
            party:broadcastPartyLoot(text)
        else
            player:sendTextMessage(MESSAGE_INFO_DESCR, text)
        end
    end
end

ec:register()
