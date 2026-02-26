function onUse(cid, item, frompos, item2, topos)
gatepos = {x=32118, y=32059, z=12, stackpos=1}
getgate = getThingfromPos(gatepos)

if item.itemid == 1945 then
doRemoveItem(getgate.uid,1)
doTransformItem(item.uid,item.itemid+1)

elseif item.itemid == 1946 then
doRemoveItem(getgate.uid,1)
doCreateItem(1025,1,gatepos)
doTransformItem(item.uid,item.itemid-1)
else
doPlayerSendCancel(cid,"Sorry not possible.")
end
  return 1
  end
  