function onUse(cid, item, fromPosition, itemEx, toPosition, isHotkey)
	if itemEx.itemid == 2782 then
		itemEx:transform(2781)
		itemEx:decay()
		return true
	end
	return destroyItem(cid, itemEx, toPosition)
end
