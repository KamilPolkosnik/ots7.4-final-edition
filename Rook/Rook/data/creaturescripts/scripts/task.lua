function onKill(cid, target)
    local player = Player(cid)
    if not player then
        return true
    end

    local targetName = getCreatureName(target)
    local monsterTarget = Monster(target)
    if monsterTarget then
        targetName = monsterTarget:getName() or targetName
    end

    if isMonster(target) then
        if BestiarySystem and BestiarySystem.onKill then
            BestiarySystem.onKill(player, targetName)
        end

        local monsterIndex = TaskSystem.getIndexByName(targetName)
        if monsterIndex then
            local required = player:getStorageValue(TaskSystem.getActiveStorageKey(monsterIndex))
            if required and required > 0 then
                local key = TaskSystem.getStorageKey(monsterIndex)
                local killCount = player:getStorageValue(key)
                if killCount < 0 then
                    killCount = 0
                end

                killCount = killCount + 1
                player:setStorageValue(key, killCount)
                TaskSystem.sendTaskUpdate(player, monsterIndex, killCount, required, 1)

                if killCount >= required then
                    TaskSystem.finishTask(player, monsterIndex, required)
                end
            end
        end
    end

    return true
end
