local FIX_KEY = {
  pos = Position(32145, 32101, 11),
  itemid = 2089,
  aid = 4601,
  keynumber = 4601
}

local FIX_DOOR = {
  pos = Position(32145, 32100, 11),
  itemid = 1212,
  aid = 4601
}

local function getItemAt(pos, itemid)
  local tile = Tile(pos)
  if not tile then
    return nil
  end
  return tile:getItemById(itemid)
end

function onStartup()
  local applied = 0
  local missing = 0

  local key = getItemAt(FIX_KEY.pos, FIX_KEY.itemid)
  if key then
    key:setActionId(FIX_KEY.aid)
    if ITEM_ATTRIBUTE_KEYNUMBER then
      key:setAttribute(ITEM_ATTRIBUTE_KEYNUMBER, FIX_KEY.keynumber)
    end
    applied = applied + 1
  else
    missing = missing + 1
  end

  local door = getItemAt(FIX_DOOR.pos, FIX_DOOR.itemid)
  if door then
    door:setActionId(FIX_DOOR.aid)
    applied = applied + 1
  else
    missing = missing + 1
  end

  print(string.format("[Key4601DoorFixup] applied=%d missing=%d", applied, missing))
  return true
end
