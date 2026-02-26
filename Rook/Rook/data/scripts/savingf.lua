local function savePlayer(player)
    if not player:save() then
        player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Failed to save your data.")
        return
    end

    player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, "Your data has been successfully saved.")
end

local function savePlayersCoroutine()
    local index = 0
    local playersId = {}
    for _, player in ipairs(Game.getPlayers()) do
        index = index + 1
        playersId[index] = player:getId()
    end

    local batchSize = 10
    return coroutine.create(function()
        for i, playerId in ipairs(playersId) do
            local player = Player(playerId)
            if player then savePlayer(player) end
            if i % batchSize == 0 then coroutine.yield() end
        end
    end)
end

local savePlayersCo = nil

local savePlayersBatch = GlobalEvent("SavePlayersBatch")

function savePlayersBatch.onThink(interval)
    savePlayersCo = savePlayersCo or savePlayersCoroutine()
    coroutine.resume(savePlayersCo)
    if coroutine.status(savePlayersCo) == "dead" then savePlayersCo = nil end
    return true
end

savePlayersBatch:interval(1000 * 60)
savePlayersBatch:register()