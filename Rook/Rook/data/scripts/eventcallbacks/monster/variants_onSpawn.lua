local ec = EventCallback

local function scheduleVariantEffect(cid, effect, interval)
  if effect <= 0 or interval <= 0 then
    return
  end

  addEvent(function()
    local monster = Monster(cid)
    if not monster then
      return
    end

    monster:getPosition():sendMagicEffect(effect)
    scheduleVariantEffect(cid, effect, interval)
  end, interval)
end

ec.onSpawn = function(self, position, startup, artificial)
  local cfg = MonsterVariants
  if not cfg or not cfg.enabled then
    return true
  end

  if cfg.skipStartupSpawns and startup then
    return true
  end

  if cfg.excludeSummons and self:getMaster() then
    return true
  end

  local mType = self:getType()
  if cfg.excludeBosses and mType:isBoss() then
    return true
  end

  if cfg.excludeUnhostile and not mType:isHostile() then
    return true
  end

  local name = mType:getName()
  if cfg.allowedNames and not cfg.allowedNames[name] then
    return true
  end

  if cfg.excludedNames and cfg.excludedNames[name] then
    return true
  end

  local roll = math.random(100)
  local selected = nil
  for i = 1, #cfg.tiers do
    local tier = cfg.tiers[i]
    local chance = tonumber(tier.chance) or 0
    if chance > 0 then
      if roll <= chance then
        selected = tier
        break
      end
      roll = roll - chance
    end
  end

  if not selected then
    return true
  end

  local mult = tonumber(selected.multiplier) or 1
  if mult > 0 then
    local oldMax = self:getMaxHealth()
    local newMax = math.max(1, math.floor(oldMax * mult + 0.5))
    if newMax ~= oldMax then
      self:setMaxHealth(newMax)
      self:setHealth(newMax)
    end
  end

  if selected.id == 1 then
    self:setSkull(SKULL_GREEN)
  elseif selected.id == 2 then
    self:setSkull(SKULL_YELLOW)
  elseif selected.id == 3 then
    self:setSkull(SKULL_RED)
  end

  local effect = tonumber(selected.effect)
  if effect and effect > 0 then
    local pos = position or self:getPosition()
    pos:sendMagicEffect(effect)
    scheduleVariantEffect(self:getId(), effect, tonumber(cfg.effectInterval) or 0)
  end

  return true
end

ec:register()
