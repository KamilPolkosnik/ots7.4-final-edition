local FIXES = {
  {x=32675, y=31671, z=10, itemid=1212, aid=3012},
  {x=32675, y=31649, z=10, itemid=1212, aid=3012},
}

function onStartup()
  local applied = 0
  local missing = 0
  for i = 1, #FIXES do
    local f = FIXES[i]
    local tile = Tile(Position(f.x, f.y, f.z))
    if tile then
      local item = tile:getItemById(f.itemid)
      if item then
        item:setActionId(f.aid)
        applied = applied + 1
      else
        missing = missing + 1
      end
    else
      missing = missing + 1
    end
  end
  print(string.format("[Key3012DoorFixup] applied=%d missing=%d", applied, missing))
  return true
end
