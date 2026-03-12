local WINGS_SPEED_BONUS = 5
local AURA_SPEED_BONUS = 3
local SHADER_SPEED_BONUS = 2
local WINGS_SPEED_STORAGE = 78031

local function hasWingsActive(outfit)
	return outfit and tonumber(outfit.lookWings or 0) > 0
end

local function hasAuraActive(outfit)
	return outfit and tonumber(outfit.lookAura or 0) > 0
end

local function hasShaderActive(outfit)
	return outfit and tonumber(outfit.lookShader or 0) > 0
end

local function getAppliedBonus(player)
	local value = tonumber(player:getStorageValue(WINGS_SPEED_STORAGE)) or -1
	if value < 0 then
		return 0
	end
	return value
end

local function setAppliedBonus(player, bonus)
	player:setStorageValue(WINGS_SPEED_STORAGE, bonus)
end

local function syncWingSpeed(player, outfit)
	local targetBonus = 0
	if hasWingsActive(outfit) then
		targetBonus = targetBonus + WINGS_SPEED_BONUS
	end
	if hasAuraActive(outfit) then
		targetBonus = targetBonus + AURA_SPEED_BONUS
	end
	if hasShaderActive(outfit) then
		targetBonus = targetBonus + SHADER_SPEED_BONUS
	end

	local appliedBonus = getAppliedBonus(player)
	local delta = targetBonus - appliedBonus
	if delta ~= 0 then
		player:changeSpeed(delta)
		setAppliedBonus(player, targetBonus)
	elseif appliedBonus ~= targetBonus then
		setAppliedBonus(player, targetBonus)
	end
end

local onChangeOutfit = EventCallback

function onChangeOutfit.onChangeOutfit(creature, outfit)
	local player = Player(creature:getId())
	if not player then
		return true
	end

	syncWingSpeed(player, outfit)
	return true
end

onChangeOutfit:register()

local wingsSpeedLogin = CreatureEvent("WingsSpeedLogin")
local wingsSpeedLogout = CreatureEvent("WingsSpeedLogout")

function wingsSpeedLogin.onLogin(player)
	player:setStorageValue(WINGS_SPEED_STORAGE, -1)
	syncWingSpeed(player, player:getOutfit())
	return true
end

function wingsSpeedLogout.onLogout(player)
	player:setStorageValue(WINGS_SPEED_STORAGE, -1)
	return true
end

wingsSpeedLogin:type("login")
wingsSpeedLogin:register()
wingsSpeedLogout:type("logout")
wingsSpeedLogout:register()
