local t = {
	useOn = 2147,
	newId = 2343
}
function onUse(cid, item, fromPosition, itemEx, toPosition)
    if itemEx.itemid == t.useOn then
		doRemoveItem(itemEx.uid, 1)
		doTransformItem(item.uid, t.newId)
		doSendMagicEffect(toPosition, CONST_ME_HOLYDAMAGE)
	else
	end
	return true
end