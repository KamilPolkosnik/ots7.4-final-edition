-- Author: 		Rodrigo (Nottinghster) - (OTLand, OTFans, XTibia, OTServBR)
-- Country:		Brazil
-- From: 		Tibia World RPG OldSchool
-- Email: 		god.rodrigo@hotmail.com
-- Compiler:	Tibia World Script Maker (Action)

function onUse(cid, item, fromPosition, itemEx, toPosition)
    
removals = {
{ item = 3474, pos = { x = 32864 , y = 32556 , z = 11 } },       
{ item = 3475, pos = { x = 32865 , y = 32556 , z = 11 } }    
}

switchpos1 = {x=32862, y=32557, z=11}
switchpos2 = {x=32862, y=32555, z=11}
dumppos1 = {x=32864, y=32557, z=11}
dumppos2 = {x=32865, y=32557, z=11}

gatepos1 = {x=32864, y=32556, z=11}
gatepos2 = {x=32865, y=32556, z=11}

if item.itemid == 1945 then       
for i = 1, #removals do            
removals[i].pos.stackpos = 1           
doRemoveItem(getThingfromPos(removals[i].pos).uid, 1)
end
doTransformItem(getTileItemById(switchpos1, 1945).uid,1946)
doTransformItem(getTileItemById(switchpos2, 1945).uid,1946)	
elseif item.itemid == 1946 then    
BridgeRelocate(gatepos1, dumppos1)
BridgeRelocate(gatepos2, dumppos2)
for i = 1, #removals do           
doCreateItem(removals[i].item, 1, removals[i].pos)
end     
doTransformItem(getTileItemById(switchpos1, 1946).uid,1945)
doTransformItem(getTileItemById(switchpos2, 1946).uid,1945) 
end   
return true
end  