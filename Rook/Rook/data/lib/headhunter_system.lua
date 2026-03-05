HeadhunterSystem = HeadhunterSystem or {}

HeadhunterSystem.OPCODE = 115
HeadhunterSystem.respecCost = 5000
HeadhunterSystem.minReward = 1
HeadhunterSystem.maxReward = 2000000000
HeadhunterSystem.maxDescriptionLength = 220
HeadhunterSystem.maxTargetLength = 30
HeadhunterSystem.maxListEntries = 500
HeadhunterSystem.maxLeaderboardEntries = 100

local function logHeadhunter(message)
    print("[Headhunter] " .. tostring(message))
end

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function sanitizeText(value, maxLength)
    local text = trim(value):gsub("[%z\1-\31]", " ")
    if maxLength and maxLength > 0 and #text > maxLength then
        text = text:sub(1, maxLength)
    end
    return text
end

local function formatMoney(value)
    local amount = math.max(0, math.floor(tonumber(value) or 0))
    local formatted = tostring(amount)
    while true do
        local replacements
        formatted, replacements = formatted:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
        if replacements == 0 then
            break
        end
    end
    return formatted
end

local function parseRows(resultId, parser)
    local rows = {}
    if not resultId then
        return rows
    end

    repeat
        rows[#rows + 1] = parser(resultId)
    until not result.next(resultId)
    result.free(resultId)

    return rows
end

local function sendPayload(player, payload)
    local encoded = json.encode(payload)
    if TaskSystem and TaskSystem.sendChunked then
        TaskSystem.sendChunked(player, HeadhunterSystem.OPCODE, encoded)
    else
        player:sendExtendedOpcode(HeadhunterSystem.OPCODE, encoded)
    end
end

local function sendResult(player, ok, message)
    sendPayload(player, {
        action = "result",
        data = {
            ok = ok and true or false,
            message = tostring(message or "")
        }
    })
end

local function columnExists(tableName, columnName)
    local query = string.format("SHOW COLUMNS FROM `%s` LIKE %s", tableName, db.escapeString(columnName))
    local resultId = db.storeQuery(query)
    if not resultId then
        return false
    end
    result.free(resultId)
    return true
end

local function ensureColumn(tableName, columnName, definition)
    if columnExists(tableName, columnName) then
        return
    end
    db.query(string.format("ALTER TABLE `%s` ADD COLUMN `%s` %s", tableName, columnName, definition))
end

function HeadhunterSystem.ensureSchema()
    if HeadhunterSystem._schemaReady then
        return
    end

    db.query([[
        CREATE TABLE IF NOT EXISTS `headhunter_bounties` (
            `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
            `issuer_guid` INT NOT NULL,
            `issuer_name` VARCHAR(255) NOT NULL,
            `target_guid` INT NOT NULL,
            `target_name` VARCHAR(255) NOT NULL,
            `reward` BIGINT UNSIGNED NOT NULL,
            `description` VARCHAR(255) NOT NULL,
            `anonymous` TINYINT(1) NOT NULL DEFAULT 0,
            `created_at` BIGINT NOT NULL,
            `active` TINYINT(1) NOT NULL DEFAULT 1,
            `claimed_by_guid` INT NOT NULL DEFAULT 0,
            `claimed_by_name` VARCHAR(255) NOT NULL DEFAULT '',
            `claimed_at` BIGINT NOT NULL DEFAULT 0,
            PRIMARY KEY (`id`),
            KEY `idx_active_target` (`active`, `target_guid`),
            KEY `idx_active_created` (`active`, `created_at`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ]])

    db.query([[
        CREATE TABLE IF NOT EXISTS `headhunter_leaderboard` (
            `player_guid` INT NOT NULL,
            `player_name` VARCHAR(255) NOT NULL,
            `kills` INT NOT NULL DEFAULT 0,
            `rewards_total` BIGINT UNSIGNED NOT NULL DEFAULT 0,
            `updated_at` BIGINT NOT NULL DEFAULT 0,
            PRIMARY KEY (`player_guid`),
            KEY `idx_kills` (`kills`, `rewards_total`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ]])

    ensureColumn("headhunter_bounties", "anonymous", "TINYINT(1) NOT NULL DEFAULT 0")

    HeadhunterSystem._schemaReady = true
end

local function findPlayerByName(name)
    local escapedName = db.escapeString(name)
    local query = "SELECT `id`, `name` FROM `players` WHERE LOWER(`name`) = LOWER(" .. escapedName .. ") LIMIT 1"
    local resultId = db.storeQuery(query)
    if not resultId then
        return nil
    end

    local data = {
        guid = tonumber(result.getNumber(resultId, "id")) or 0,
        name = tostring(result.getString(resultId, "name") or "")
    }
    result.free(resultId)
    if data.guid <= 0 or data.name == "" then
        return nil
    end
    return data
end

local function buildActiveBountiesForViewer(viewerGuid)
    local query = string.format(
        "SELECT `id`, `issuer_guid`, `issuer_name`, `target_name`, `reward`, `description`, `anonymous`, `created_at` FROM `headhunter_bounties` WHERE `active` = 1 ORDER BY `created_at` DESC, `id` DESC LIMIT %d",
        HeadhunterSystem.maxListEntries
    )
    local resultId = db.storeQuery(query)
    return parseRows(resultId, function(row)
        local issuerGuid = tonumber(result.getNumber(row, "issuer_guid")) or 0
        local isAnonymous = tonumber(result.getNumber(row, "anonymous")) == 1
        local issuerName = tostring(result.getString(row, "issuer_name") or "")
        local issuerVisible = (not isAnonymous)
        return {
            id = tonumber(result.getNumber(row, "id")) or 0,
            issuer = issuerVisible and issuerName or "Anonymous",
            target = tostring(result.getString(row, "target_name") or ""),
            reward = tonumber(result.getNumber(row, "reward")) or 0,
            description = tostring(result.getString(row, "description") or ""),
            createdAt = tonumber(result.getNumber(row, "created_at")) or 0,
            canWithdraw = issuerGuid > 0 and viewerGuid > 0 and issuerGuid == viewerGuid,
            anonymous = isAnonymous
        }
    end)
end

local function buildLeaderboard()
    local query = string.format(
        "SELECT `player_name`, `kills`, `rewards_total` FROM `headhunter_leaderboard` ORDER BY `kills` DESC, `rewards_total` DESC, `player_name` ASC LIMIT %d",
        HeadhunterSystem.maxLeaderboardEntries
    )
    local resultId = db.storeQuery(query)
    return parseRows(resultId, function(row)
        return {
            name = tostring(result.getString(row, "player_name") or ""),
            kills = tonumber(result.getNumber(row, "kills")) or 0,
            rewards = tonumber(result.getNumber(row, "rewards_total")) or 0
        }
    end)
end

function HeadhunterSystem.buildSnapshotData()
    return HeadhunterSystem.buildSnapshotDataForViewer(0)
end

function HeadhunterSystem.buildSnapshotDataForViewer(viewerGuid)
    HeadhunterSystem.ensureSchema()
    viewerGuid = math.max(0, math.floor(tonumber(viewerGuid) or 0))
    return {
        bounties = buildActiveBountiesForViewer(viewerGuid),
        leaderboard = buildLeaderboard(),
        respecCost = HeadhunterSystem.respecCost
    }
end

function HeadhunterSystem.sendSnapshot(player, cachedData)
    if not player or not player:isPlayer() then
        return
    end

    local data = cachedData or HeadhunterSystem.buildSnapshotDataForViewer(player:getGuid())
    sendPayload(player, {action = "snapshot", data = data})
end

function HeadhunterSystem.broadcastSnapshot()
    local players = Game.getPlayers()
    if not players then
        return
    end

    for _, player in ipairs(players) do
        if player and player:isPlayer() then
            HeadhunterSystem.sendSnapshot(player)
        end
    end
end

function HeadhunterSystem.createBounty(player, targetName, rewardValue, description, anonymous)
    HeadhunterSystem.ensureSchema()

    if not player or not player:isPlayer() then
        return false
    end

    local cleanTarget = sanitizeText(targetName, HeadhunterSystem.maxTargetLength)
    local cleanDescription = sanitizeText(description, HeadhunterSystem.maxDescriptionLength)
    local reward = math.floor(tonumber(rewardValue) or 0)
    local isAnonymous = (anonymous == true) and 1 or 0

    if cleanTarget == "" then
        sendResult(player, false, "Enter target player name.")
        return false
    end

    if reward < HeadhunterSystem.minReward or reward > HeadhunterSystem.maxReward then
        sendResult(player, false, "Invalid reward amount.")
        return false
    end

    if cleanDescription == "" then
        sendResult(player, false, "Enter bounty description.")
        return false
    end

    local targetData = findPlayerByName(cleanTarget)
    if not targetData then
        sendResult(player, false, "Player not found in database.")
        return false
    end

    if targetData.guid == player:getGuid() then
        sendResult(player, false, "You cannot place a bounty on yourself.")
        return false
    end

    if player:getMoney() < reward then
        sendResult(player, false, "Not enough gold in backpack.")
        return false
    end

    if not player:removeMoney(reward) then
        sendResult(player, false, "Could not remove gold from backpack.")
        return false
    end

    local query = string.format(
        "INSERT INTO `headhunter_bounties` (`issuer_guid`, `issuer_name`, `target_guid`, `target_name`, `reward`, `description`, `anonymous`, `created_at`, `active`) VALUES (%d, %s, %d, %s, %d, %s, %d, %d, 1)",
        player:getGuid(),
        db.escapeString(player:getName()),
        targetData.guid,
        db.escapeString(targetData.name),
        reward,
        db.escapeString(cleanDescription),
        isAnonymous,
        os.time()
    )

    if not db.query(query) then
        player:addMoney(reward)
        sendResult(player, false, "Could not create bounty. Gold was returned.")
        return false
    end

    sendResult(
        player,
        true,
        string.format("Bounty placed on %s for %s gp.", targetData.name, formatMoney(reward))
    )

    local targetOnline = Player(targetData.name)
    if targetOnline and targetOnline:isPlayer() then
        targetOnline:sendTextMessage(
            MESSAGE_STATUS_CONSOLE_ORANGE,
            string.format(
                "%s has placed a bounty on your head (%s gp).",
                (isAnonymous == 1) and "An anonymous player" or player:getName(),
                formatMoney(reward)
            )
        )
    end

    HeadhunterSystem.broadcastSnapshot()
    return true
end

function HeadhunterSystem.withdrawBounty(player, bountyId)
    HeadhunterSystem.ensureSchema()

    if not player or not player:isPlayer() then
        return false
    end

    local id = math.floor(tonumber(bountyId) or 0)
    if id <= 0 then
        sendResult(player, false, "Invalid bounty id.")
        return false
    end

    local query = string.format(
        "SELECT `issuer_guid`, `target_name`, `reward` FROM `headhunter_bounties` WHERE `id` = %d AND `active` = 1 LIMIT 1",
        id
    )
    local resultId = db.storeQuery(query)
    if not resultId then
        sendResult(player, false, "Bounty is no longer active.")
        return false
    end

    local issuerGuid = tonumber(result.getNumber(resultId, "issuer_guid")) or 0
    local targetName = tostring(result.getString(resultId, "target_name") or "")
    local reward = tonumber(result.getNumber(resultId, "reward")) or 0
    result.free(resultId)

    if issuerGuid ~= player:getGuid() then
        sendResult(player, false, "You can withdraw only your own bounties.")
        return false
    end

    if reward <= 0 then
        sendResult(player, false, "Invalid bounty reward.")
        return false
    end

    local updateQuery = string.format(
        "UPDATE `headhunter_bounties` SET `active` = 0, `claimed_by_guid` = %d, `claimed_by_name` = %s, `claimed_at` = %d WHERE `id` = %d AND `active` = 1",
        player:getGuid(),
        db.escapeString("withdrawn"),
        os.time(),
        id
    )
    if not db.query(updateQuery) then
        sendResult(player, false, "Could not withdraw bounty.")
        return false
    end

    player:addMoney(reward)
    sendResult(
        player,
        true,
        string.format("Bounty on %s withdrawn. %s gp returned to you.", targetName ~= "" and targetName or "target", formatMoney(reward))
    )

    HeadhunterSystem.broadcastSnapshot()
    return true
end

local function collectActiveBountyIds(targetGuid)
    local query = "SELECT `id`, `reward` FROM `headhunter_bounties` WHERE `active` = 1 AND `target_guid` = " .. targetGuid
    local resultId = db.storeQuery(query)
    if not resultId then
        return nil
    end

    local ids = {}
    local totalReward = 0
    local count = 0
    repeat
        local bountyId = tonumber(result.getNumber(resultId, "id")) or 0
        local reward = tonumber(result.getNumber(resultId, "reward")) or 0
        if bountyId > 0 and reward > 0 then
            ids[#ids + 1] = bountyId
            totalReward = totalReward + reward
            count = count + 1
        end
    until not result.next(resultId)
    result.free(resultId)

    if count == 0 then
        return nil
    end

    return ids, totalReward, count
end

local function addLeaderboardKill(killer, reward)
    local query = string.format(
        "INSERT INTO `headhunter_leaderboard` (`player_guid`, `player_name`, `kills`, `rewards_total`, `updated_at`) VALUES (%d, %s, 1, %d, %d) ON DUPLICATE KEY UPDATE `player_name` = VALUES(`player_name`), `kills` = `kills` + 1, `rewards_total` = `rewards_total` + VALUES(`rewards_total`), `updated_at` = VALUES(`updated_at`)",
        killer:getGuid(),
        db.escapeString(killer:getName()),
        reward,
        os.time()
    )
    db.query(query)
end

function HeadhunterSystem.onPlayerKilled(victim, killer)
    HeadhunterSystem.ensureSchema()

    if not victim or not victim:isPlayer() or not killer or not killer:isPlayer() then
        return false
    end

    if victim:getGuid() == killer:getGuid() then
        return false
    end

    local ids, totalReward, bountyCount = collectActiveBountyIds(victim:getGuid())
    if not ids or bountyCount <= 0 or totalReward <= 0 then
        return false
    end

    local idList = table.concat(ids, ",")
    local updateQuery = string.format(
        "UPDATE `headhunter_bounties` SET `active` = 0, `claimed_by_guid` = %d, `claimed_by_name` = %s, `claimed_at` = %d WHERE `id` IN (%s)",
        killer:getGuid(),
        db.escapeString(killer:getName()),
        os.time(),
        idList
    )
    db.query(updateQuery)

    killer:addMoney(totalReward)
    addLeaderboardKill(killer, totalReward)

    killer:sendTextMessage(
        MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format(
            "You claimed %d bounty contract(s) on %s and received %s gp.",
            bountyCount,
            victim:getName(),
            formatMoney(totalReward)
        )
    )

    victim:sendTextMessage(
        MESSAGE_STATUS_CONSOLE_ORANGE,
        string.format(
            "Your bounty was claimed by %s (%s gp).",
            killer:getName(),
            formatMoney(totalReward)
        )
    )

    logHeadhunter(
        string.format(
            "claimed victim=%s killer=%s count=%d reward=%d",
            victim:getName(),
            killer:getName(),
            bountyCount,
            totalReward
        )
    )

    HeadhunterSystem.broadcastSnapshot()
    return true
end

HeadhunterSystem.ensureSchema()
