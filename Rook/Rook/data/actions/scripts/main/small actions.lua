
--1000 - 1999 is reserved storage ids for Main quests only--

function onUse(cid, item, frompos, item2, topos)
-- Fibula Draw Well --
if item.uid == 5620 then
NEWPOS = {x=32172, y=32439, z=8}
doTeleportThing(cid, NEWPOS)
-----
-----
-- Fibula ladder --
elseif item.uid == 9927 then
NEWPOS = {x=32172, y=32439, z=7}
doTeleportThing(cid, NEWPOS)
-----
-----
-- Ghoul Room Draw Well --
elseif item.uid == 5621 then
NEWPOS = {x=32508, y=32176, z=14}
doTeleportThing(cid, NEWPOS)
-----
-----
else	
  return 0
end
return 1
end
