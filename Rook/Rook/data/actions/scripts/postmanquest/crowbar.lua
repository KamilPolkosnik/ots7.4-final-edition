function onUse(cid, item, fromPosition, itemEx, toPosition)

local mailuid = 9120
local storage = 250
local getstorage = getPlayerStorageValue(cid, storage)

	if(itemEx.itemid == 2593 and itemEx.uid == mailuid and getstorage == 3) then
		doSendMagicEffect(toPosition, 14)
		setPlayerStorageValue(cid, storage, 4)
		return true
	end
	
end