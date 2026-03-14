BoostedCreatureDaily = BoostedCreatureDaily or {}

local SYSTEM = BoostedCreatureDaily

SYSTEM.MIN_EXP_BONUS = 2
SYSTEM.MAX_EXP_BONUS = 10
SYSTEM.MIN_LOOT_BONUS = 1
SYSTEM.MAX_LOOT_BONUS = 5
SYSTEM.HOLOGRAM_MONSTER = "Market Stall"
SYSTEM.THINK_INTERVAL_MS = 1000
SYSTEM.HOLOGRAM_REFRESH_INTERVAL_MS = 15 * 1000
SYSTEM.HOLOGRAM_ANNOUNCE_INTERVAL_SEC = 5

SYSTEM._pool = SYSTEM._pool or {}
SYSTEM._poolByKey = SYSTEM._poolByKey or {}
SYSTEM._holograms = SYSTEM._holograms or {}
SYSTEM._current = SYSTEM._current or nil
SYSTEM._lastHologramRefresh = SYSTEM._lastHologramRefresh or 0
SYSTEM._hologramNextAnnounceAt = SYSTEM._hologramNextAnnounceAt or {}
SYSTEM._monsterFileByName = SYSTEM._monsterFileByName or {}

local function normalizeName(name)
	return string.lower((tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")))
end

local function hashString(input)
	local h = 2166136261
	for i = 1, #input do
		h = bit.bxor(h, string.byte(input, i))
		h = (h * 16777619) % 4294967296
	end
	return h
end

local function clampPercent(value, minValue, maxValue)
	value = math.floor(tonumber(value) or minValue)
	if value < minValue then
		return minValue
	end
	if value > maxValue then
		return maxValue
	end
	return value
end

local function getSpawnFilePath()
	local mapName = configManager.getString(configKeys.MAP_NAME) or "world"
	return "data/world/" .. mapName .. "-spawn.xml"
end

local function loadMonsterFileIndex()
	SYSTEM._monsterFileByName = {}

	local file = io.open("data/monster/monsters.xml", "r")
	if not file then
		return
	end

	local content = file:read("*a") or ""
	file:close()

	for name, path in content:gmatch("<monster%s+name=\"([^\"]+)\"%s+file=\"([^\"]+)\"") do
		SYSTEM._monsterFileByName[normalizeName(name)] = tostring(path)
	end
end

local function isBossMonsterName(monsterName)
	local path = SYSTEM._monsterFileByName[normalizeName(monsterName)]
	if not path or path == "" then
		return false
	end

	local lowered = string.lower(path:gsub("\\", "/"))
	return lowered:find("bosses/", 1, true) ~= nil
end

local function canUseMonsterName(monsterName)
	local key = normalizeName(monsterName)
	if key == "" or SYSTEM._poolByKey[key] then
		return false
	end

	if isBossMonsterName(monsterName) then
		return false
	end

	local monsterType = MonsterType(monsterName)
	if not monsterType then
		return false
	end

	local exp = tonumber(monsterType:getExperience()) or 0
	if exp <= 0 then
		return false
	end

	return true
end

function SYSTEM.buildMonsterPool()
	SYSTEM._pool = {}
	SYSTEM._poolByKey = {}
	loadMonsterFileIndex()

	local path = getSpawnFilePath()
	local file = io.open(path, "r")
	if not file then
		print(string.format("[BoostedCreatureDaily] Failed to open spawn file: %s", path))
		return false
	end

	local content = file:read("*a") or ""
	file:close()

	for rawName in content:gmatch("<monster%s+name=\"([^\"]+)\"") do
		if canUseMonsterName(rawName) then
			local monsterType = MonsterType(rawName)
			local displayName = monsterType and monsterType:getName() or rawName
			local key = normalizeName(displayName)
			SYSTEM._pool[#SYSTEM._pool + 1] = displayName
			SYSTEM._poolByKey[key] = true
		end
	end

	table.sort(SYSTEM._pool)
	print(string.format("[BoostedCreatureDaily] Pool loaded: %d monsters", #SYSTEM._pool))
	return #SYSTEM._pool > 0
end

local function findTempleHologramPosition(templePosition)
	local offsets = {
		{x = 2, y = 0},
		{x = -2, y = 0},
		{x = 0, y = 2},
		{x = 0, y = -2},
		{x = 2, y = 1},
		{x = 2, y = -1},
		{x = -2, y = 1},
		{x = -2, y = -1},
		{x = 1, y = 2},
		{x = -1, y = 2},
		{x = 1, y = -2},
		{x = -1, y = -2},
		{x = 3, y = 0},
		{x = -3, y = 0},
		{x = 0, y = 3},
		{x = 0, y = -3}
	}

	for _, offset in ipairs(offsets) do
		local pos = Position(templePosition.x + offset.x, templePosition.y + offset.y, templePosition.z)
		local tile = Tile(pos)
		if tile and tile:hasFlag(TILESTATE_PROTECTIONZONE) and not tile:getTopCreature() then
			return pos
		end
	end

	return Position(templePosition.x + 2, templePosition.y, templePosition.z)
end

local function removeHolograms()
	for _, cid in pairs(SYSTEM._holograms) do
		local creature = Creature(cid)
		if creature then
			creature:remove()
		end
	end
	SYSTEM._holograms = {}
	SYSTEM._hologramNextAnnounceAt = {}
end

function SYSTEM.spawnTempleHolograms()
	removeHolograms()

	local current = SYSTEM._current
	if not current or not current.monsterName then
		return
	end

	local monsterType = MonsterType(current.monsterName)
	if not monsterType then
		return
	end

	local outfit = monsterType:getOutfit()
	local towns = Game.getTowns()
	for _, town in ipairs(towns) do
		local templePos = town:getTemplePosition()
		if templePos then
			local spawnPos = findTempleHologramPosition(templePos)
			local hologram = Game.createMonster(SYSTEM.HOLOGRAM_MONSTER, spawnPos, false, true)
			if hologram then
				if outfit and tonumber(outfit.lookType or 0) > 0 then
					hologram:setOutfit(outfit)
				end
				pcall(function()
					local titleName = string.format("Boosted creature - %s", tostring(current.monsterName or "Unknown"))
					hologram:rename(titleName, "a boosted creature")
				end)
				hologram:setSkull(SKULL_GREEN)
				SYSTEM._holograms[town:getId()] = hologram:getId()
				SYSTEM._hologramNextAnnounceAt[hologram:getId()] = os.time() + 1
			end
		end
	end

	SYSTEM._lastHologramRefresh = os.time()
end

local function updateHologramTexts()
	local current = SYSTEM._current
	if not current then
		return
	end

	local now = os.time()
	local line = string.format("Boosted exp %d%% | Boosted loot %d%%", current.expBonus, current.lootBonus)
	for _, cid in pairs(SYSTEM._holograms) do
		local creature = Creature(cid)
		if creature then
			local nextAt = tonumber(SYSTEM._hologramNextAnnounceAt[cid]) or 0
			if now >= nextAt then
				creature:say(line, TALKTYPE_MONSTER_SAY)
				SYSTEM._hologramNextAnnounceAt[cid] = now + SYSTEM.HOLOGRAM_ANNOUNCE_INTERVAL_SEC
			end
		end
	end
end

local function refreshHologramsIfNeeded()
	local now = os.time()
	if now - SYSTEM._lastHologramRefresh < math.floor(SYSTEM.HOLOGRAM_REFRESH_INTERVAL_MS / 1000) then
		return
	end

	local needsRespawn = false
	for _, cid in pairs(SYSTEM._holograms) do
		if not Creature(cid) then
			needsRespawn = true
			break
		end
	end

	if needsRespawn then
		SYSTEM.spawnTempleHolograms()
	else
		SYSTEM._lastHologramRefresh = now
	end
end

local function computeDailyState(dayKey)
	if #SYSTEM._pool == 0 and not SYSTEM.buildMonsterPool() then
		return nil
	end

	local dayToken = tostring(dayKey or os.date("%Y-%m-%d"))
	local creatureIndex = (hashString(dayToken .. ":creature") % #SYSTEM._pool) + 1
	local expSpread = SYSTEM.MAX_EXP_BONUS - SYSTEM.MIN_EXP_BONUS + 1
	local lootSpread = SYSTEM.MAX_LOOT_BONUS - SYSTEM.MIN_LOOT_BONUS + 1
	local expBonus = SYSTEM.MIN_EXP_BONUS + (hashString(dayToken .. ":exp") % expSpread)
	local lootBonus = SYSTEM.MIN_LOOT_BONUS + (hashString(dayToken .. ":loot") % lootSpread)

	local monsterName = SYSTEM._pool[creatureIndex]
	return {
		dayKey = dayToken,
		monsterName = monsterName,
		monsterKey = normalizeName(monsterName),
		expBonus = clampPercent(expBonus, SYSTEM.MIN_EXP_BONUS, SYSTEM.MAX_EXP_BONUS),
		lootBonus = clampPercent(lootBonus, SYSTEM.MIN_LOOT_BONUS, SYSTEM.MAX_LOOT_BONUS)
	}
end

function SYSTEM.refresh(force)
	local dayKey = os.date("%Y-%m-%d")
	if not force and SYSTEM._current and SYSTEM._current.dayKey == dayKey then
		refreshHologramsIfNeeded()
		return false
	end

	local daily = computeDailyState(dayKey)
	if not daily then
		return false
	end

	SYSTEM._current = daily
	SYSTEM.spawnTempleHolograms()
	Game.broadcastMessage(
		string.format(
			"[Boosted Creature] Today: %s (+%d%% EXP, +%d%% loot chance).",
			daily.monsterName,
			daily.expBonus,
			daily.lootBonus
		),
		MESSAGE_STATUS_WARNING
	)
	return true
end

function SYSTEM.getCurrent()
	return SYSTEM._current
end

function SYSTEM.getExpBonusForMonster(monster)
	local current = SYSTEM._current
	if not current then
		return 0
	end

	local name = monster
	if type(monster) ~= "string" and monster and monster.getName then
		name = monster:getName()
	end

	if normalizeName(name) == current.monsterKey then
		return current.expBonus
	end
	return 0
end

function SYSTEM.getLootBonusPercent(monster)
	local current = SYSTEM._current
	if not current then
		return 0
	end

	local name = monster
	if type(monster) ~= "string" and monster and monster.getName then
		name = monster:getName()
	end

	if normalizeName(name) == current.monsterKey then
		return current.lootBonus
	end
	return 0
end

function SYSTEM.getSummaryText()
	local current = SYSTEM._current
	if not current then
		return "Boosted creature is not ready yet."
	end

	return string.format(
		"Today's boosted creature: %s (+%d%% EXP, +%d%% loot chance).",
		current.monsterName,
		current.expBonus,
		current.lootBonus
	)
end

local boostedDailyStartup = GlobalEvent("BoostedCreatureDailyStartup")
function boostedDailyStartup.onStartup()
	SYSTEM.refresh(true)
	return true
end
boostedDailyStartup:register()

local boostedDailyThink = GlobalEvent("BoostedCreatureDailyThink")
function boostedDailyThink.onThink(interval)
	SYSTEM.refresh(false)
	updateHologramTexts()
	return true
end
boostedDailyThink:interval(SYSTEM.THINK_INTERVAL_MS)
boostedDailyThink:register()

local boostedDailyLogin = CreatureEvent("BoostedCreatureDailyLogin")
function boostedDailyLogin.onLogin(player)
	if SYSTEM and SYSTEM.getSummaryText then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_BLUE, SYSTEM.getSummaryText())
	end
	return true
end
boostedDailyLogin:type("login")
boostedDailyLogin:register()
