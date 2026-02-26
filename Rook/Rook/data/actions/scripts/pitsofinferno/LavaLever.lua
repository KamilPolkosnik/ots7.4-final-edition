function onUse(cid, item, frompos, item2, topos)

gatepos1 = {x=32927, y=32255, z=15, stackpos=0}
getgate1 = getThingfromPos(gatepos1)
gatepos2 = {x=32927, y=32255, z=15, stackpos=253}
getgate2 = getThingfromPos(gatepos2)

switchpos1 = {x=32933, y=32261, z=15}
dumppos = {x=32927, y=32256, z=15}
	
if item.itemid == 1945 then	
doCreateItem(407,1,gatepos1)
doTransformItem(getTileItemById(switchpos1, 1945).uid,1946)	
elseif item.itemid == 1946 then
doCreateItem(599,1,gatepos1)
if getgate2.itemid > 0 then
doTeleportThing(getgate2.uid,dumppos)
end
doTransformItem(getTileItemById(switchpos1, 1946).uid,1945)	
else
doPlayerSendCancel(cid,"Sorry not possible.")
end
  return 1
  end
