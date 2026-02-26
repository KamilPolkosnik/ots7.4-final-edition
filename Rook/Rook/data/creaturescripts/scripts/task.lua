function onKill(cid, target)
    local player = Player(cid)
    local targetName = getCreatureName(target)

    if isMonster(target) then
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
