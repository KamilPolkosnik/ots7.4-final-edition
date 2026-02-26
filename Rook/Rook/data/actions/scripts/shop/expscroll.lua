  local config = {
        rate = 1.3, -- 4x More Experience
        time = 6 * 60 * 60, -- Hours of Exp Time
        storage = 78011
    }
 
    local function endExpRate(cid)
		if isPlayer(cid) then
			doPlayerSetRate(cid, SKILL__LEVEL, 1.0) --config.lua rate
			doCreatureSetStorage(cid, config.storage, -1)
			doPlayerSendTextMessage(cid, MESSAGE_STATUS_CONSOLE_RED, "Your extra experience time has ended.")
		end
	end
 
    function onUse(cid, item, fromPosition, itemEx, toPosition)
        if(getCreatureStorage(cid, config.storage) == -1) then
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You have now 30% experience boost. It will last for 6 hours.")
			doSendMagicEffect(getPlayerPosition(cid),CONST_ME_MAGIC_RED)
            doPlayerSetRate(cid, SKILL__LEVEL, config.rate)
            doCreatureSetStorage(cid, config.storage, os.time()+config.time) 
            addEvent(endExpRate, os.time()+config.time, cid) 
            doRemoveItem(item.uid, 1)
        else
            doPlayerSendTextMessage(cid, MESSAGE_INFO_DESCR, "You still have extra experience time left.")
        end
        return true
    end 