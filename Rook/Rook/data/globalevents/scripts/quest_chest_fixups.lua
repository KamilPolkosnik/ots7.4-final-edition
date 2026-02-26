-- Ensure key quest chests have the correct Action ID after map changes.
local CHEST_IDS = {1738, 1739, 1740, 1741, 1746, 1747, 1748, 1749}
local FIXES = {
    {pos = Position(32031, 31686, 8), aid = 2000, itemid = 1740, uid = 60000},
    {pos = Position(32105, 31567, 9), aid = 2000, itemid = 1740, uid = 60001},
    {pos = Position(32109, 31567, 9), aid = 2000, itemid = 1740, uid = 60002},
    {pos = Position(32172, 31602, 10), aid = 2000, itemid = 1740, uid = 60003},
    {pos = Position(32201, 31571, 10), aid = 2000, itemid = 1740, uid = 60004},
    {pos = Position(32212, 31896, 15), aid = 2000, uid = 60005},
    {pos = Position(32212, 31910, 15), aid = 2000, uid = 60006},
    {pos = Position(32218, 31912, 15), aid = 2000, uid = 60007},
    {pos = Position(32220, 31912, 15), aid = 2000, uid = 60008},
    {pos = Position(32226, 31896, 15), aid = 2000, uid = 60009},
    {pos = Position(32226, 31910, 15), aid = 2000, uid = 60010},
    {pos = Position(32259, 31949, 14), aid = 2000, itemid = 1738, uid = 60011},
    {pos = Position(32346, 32063, 12), aid = 2000, itemid = 1740, uid = 60012},
    {pos = Position(32357, 32130, 9), aid = 2000, uid = 60013},
    {pos = Position(32376, 31802, 7), aid = 2000, uid = 60014},
    {pos = Position(32390, 31769, 9), aid = 2000, itemid = 1740, uid = 60015},
    {pos = Position(32434, 31938, 8), aid = 2000, itemid = 1741, uid = 60016},
    {pos = Position(32443, 32238, 11), aid = 2000, uid = 60017},
    {pos = Position(32451, 32048, 8), aid = 2000, itemid = 1740, uid = 60018},
    {pos = Position(32455, 31968, 14), aid = 2000, itemid = 1740, uid = 60019},
    {pos = Position(32455, 32048, 8), aid = 2000, itemid = 1740, uid = 60020},
    {pos = Position(32456, 32008, 13), aid = 2000, itemid = 1738, uid = 60021},
    {pos = Position(32459, 32144, 15), aid = 2000, itemid = 1740, uid = 60022},
    {pos = Position(32462, 31947, 4), aid = 2000, itemid = 1741, uid = 60023},
    {pos = Position(32464, 31957, 5), aid = 2000, uid = 60024},
    {pos = Position(32465, 32148, 15), aid = 2000, itemid = 1740, uid = 60025},
    {pos = Position(32466, 32148, 15), aid = 2000, itemid = 1740, uid = 60026},
    {pos = Position(32467, 31962, 4), aid = 2000, uid = 60027},
    {pos = Position(32477, 31900, 1), aid = 2000, uid = 60028},
    {pos = Position(32478, 31900, 1), aid = 2000, uid = 60029},
    {pos = Position(32479, 31611, 15), aid = 2000, uid = 60030},
    {pos = Position(32479, 31900, 1), aid = 2000, uid = 60031},
    {pos = Position(32480, 31900, 1), aid = 2000, uid = 60032},
    {pos = Position(32481, 31611, 15), aid = 2000, uid = 60033},
    {pos = Position(32495, 31992, 14), aid = 2000, itemid = 1738, uid = 60034},
    {pos = Position(32497, 31992, 14), aid = 2000, itemid = 1738, uid = 60035},
    {pos = Position(32500, 32175, 14), aid = 2000, itemid = 1740, uid = 60036},
    {pos = Position(32500, 32177, 14), aid = 2000, itemid = 1740, uid = 60037},
    {pos = Position(32504, 31596, 14), aid = 2000, itemid = 1740, uid = 60038},
    {pos = Position(32515, 31596, 14), aid = 2000, itemid = 1740, uid = 60039},
    {pos = Position(32522, 32111, 15), aid = 2000, uid = 60040},
    {pos = Position(32565, 32119, 3), aid = 2000, uid = 60041},
    {pos = Position(32567, 32024, 6), aid = 2000, itemid = 1740, uid = 60042},
    {pos = Position(32569, 32024, 6), aid = 2000, itemid = 1740, uid = 60043},
    {pos = Position(32572, 32195, 14), aid = 2000, itemid = 1740, uid = 60044},
    {pos = Position(32575, 32195, 14), aid = 2000, itemid = 1740, uid = 60045},
    {pos = Position(32578, 32195, 14), aid = 2000, itemid = 1740, uid = 60046},
    {pos = Position(32590, 31647, 3), aid = 2000, itemid = 1740, uid = 60047},
    {pos = Position(32591, 31647, 3), aid = 2000, itemid = 1740, uid = 60048},
    {pos = Position(32591, 32097, 14), aid = 2000, itemid = 1740, uid = 60049},
    {pos = Position(32598, 31934, 15), aid = 2000, itemid = 1741, uid = 60050},
    {pos = Position(32599, 31776, 9), aid = 2000, uid = 60051},
    {pos = Position(32599, 31923, 6), aid = 2000, uid = 60052},
    {pos = Position(32601, 31776, 9), aid = 2000, uid = 60053},
    {pos = Position(32605, 31908, 3), aid = 2000, uid = 60054},
    {pos = Position(32611, 32382, 10), aid = 2000, itemid = 1738, uid = 60055},
    {pos = Position(32620, 32198, 10), aid = 2000, uid = 60056},
    {pos = Position(32623, 32187, 9), aid = 2000, uid = 60057},
    {pos = Position(32644, 32131, 8), aid = 2000, itemid = 1740, uid = 60058},
    {pos = Position(32648, 31905, 3), aid = 2000, uid = 60059},
    {pos = Position(32649, 31969, 9), aid = 2000, itemid = 1740, uid = 60060},
    {pos = Position(32650, 31969, 9), aid = 2000, itemid = 1740, uid = 60061},
    {pos = Position(32651, 31969, 9), aid = 2000, itemid = 1740, uid = 60062},
    {pos = Position(32668, 32069, 8), aid = 2000, uid = 60063},
    {pos = Position(32675, 32069, 8), aid = 2000, uid = 60064},
    {pos = Position(32677, 32084, 11), aid = 2000, uid = 60065},
    {pos = Position(32704, 31605, 14), aid = 2000, itemid = 1740, uid = 60066},
    {pos = Position(32757, 31957, 9), aid = 2000, itemid = 1741, uid = 60067},
    {pos = Position(32758, 31952, 9), aid = 2000, itemid = 1741, uid = 60068},
    {pos = Position(32769, 32302, 10), aid = 2000, itemid = 1740, uid = 60069},
    {pos = Position(32774, 32253, 8), aid = 2000, itemid = 1740, uid = 60070},
    {pos = Position(32776, 32253, 8), aid = 2000, itemid = 1740, uid = 60071},
    {pos = Position(32778, 32253, 8), aid = 2000, itemid = 1740, uid = 60072},
    {pos = Position(32782, 32910, 8), aid = 2000, itemid = 1738, uid = 60073},
    {pos = Position(32803, 31582, 2), aid = 2000, uid = 60074},
    {pos = Position(32804, 31582, 2), aid = 2000, uid = 60075},
    {pos = Position(32845, 31917, 6), aid = 2000, uid = 60076},
    {pos = Position(32847, 31917, 6), aid = 2000, uid = 60077},
    {pos = Position(32852, 32332, 7), aid = 2000, uid = 60078},
    {pos = Position(32867, 31909, 8), aid = 2000, uid = 60079},
    {pos = Position(32922, 32755, 7), aid = 2000, itemid = 1740, uid = 60080},
    {pos = Position(32935, 32886, 7), aid = 2000, itemid = 1741, uid = 60081},
    {pos = Position(32957, 32834, 8), aid = 2000, itemid = 1738, uid = 60082},
    {pos = Position(32967, 31719, 2), aid = 2000, itemid = 1741, uid = 60083},
    {pos = Position(32980, 31727, 9), aid = 2000, uid = 60084},
    {pos = Position(32981, 31727, 9), aid = 2000, uid = 60085},
    {pos = Position(32985, 31727, 9), aid = 2000, uid = 60086},
    {pos = Position(33038, 32171, 9), aid = 2000, uid = 60087},
    {pos = Position(33039, 32171, 9), aid = 2000, uid = 60088},
    {pos = Position(33040, 32171, 9), aid = 2000, uid = 60089},
    {pos = Position(33072, 32169, 2), aid = 2000, uid = 60090},
    {pos = Position(33078, 31656, 11), aid = 2000, itemid = 1740, uid = 60091},
    {pos = Position(33079, 32169, 2), aid = 2000, uid = 60092},
    {pos = Position(33089, 32030, 9), aid = 2000, itemid = 1738, uid = 60093},
    {pos = Position(33095, 31800, 10), aid = 2000, itemid = 1738, uid = 60094},
    {pos = Position(33095, 31801, 10), aid = 2000, itemid = 1738, uid = 60095},
    {pos = Position(33109, 31679, 13), aid = 2000, uid = 60096},
    {pos = Position(33110, 31679, 13), aid = 2000, uid = 60097},
    {pos = Position(33131, 31624, 15), aid = 2000, itemid = 1738, uid = 60098},
    {pos = Position(33134, 31624, 15), aid = 2000, itemid = 1738, uid = 60099},
    {pos = Position(33136, 31601, 15), aid = 2000, itemid = 1738, uid = 60100},
    {pos = Position(33143, 31719, 10), aid = 2000, itemid = 1741, uid = 60101},
    {pos = Position(33143, 31721, 10), aid = 2000, itemid = 1741, uid = 60102},
    {pos = Position(33150, 32862, 7), aid = 2000, itemid = 1740, uid = 60103},
    {pos = Position(33152, 31640, 11), aid = 2000, itemid = 1738, uid = 60104},
    {pos = Position(33155, 31880, 11), aid = 2000, itemid = 1741, uid = 60105},
    {pos = Position(33158, 31621, 15), aid = 2000, itemid = 1738, uid = 60106},
    {pos = Position(33158, 31622, 15), aid = 2000, itemid = 1738, uid = 60107},
    {pos = Position(33163, 31603, 15), aid = 2000, itemid = 1738, uid = 60108},
    {pos = Position(33184, 31945, 11), aid = 2000, itemid = 1738, uid = 60109},
    {pos = Position(33185, 31945, 11), aid = 2000, itemid = 1738, uid = 60110},
    {pos = Position(33188, 31682, 14), aid = 2000, itemid = 1738, uid = 60111},
    {pos = Position(33189, 31688, 14), aid = 2000, uid = 60112},
    {pos = Position(33195, 31688, 14), aid = 2000, uid = 60113},
    {pos = Position(33199, 31923, 11), aid = 2000, itemid = 1738, uid = 60114},
    {pos = Position(33227, 31656, 13), aid = 1203, uid = 60115},
    {pos = Position(33229, 31656, 13), aid = 1203, uid = 60116},
    {pos = Position(33231, 31656, 13), aid = 1203, uid = 60117},
    {pos = Position(33233, 31656, 13), aid = 1203, uid = 60118},
    {pos = Position(33294, 31658, 13), aid = 2000, uid = 60119},
    {pos = Position(33295, 31658, 13), aid = 2000, uid = 60120},
    {pos = Position(33297, 31658, 13), aid = 2000, uid = 60121},
    {pos = Position(33298, 31658, 13), aid = 2000, uid = 60122},
    {pos = Position(33308, 32279, 12), aid = 2000, itemid = 1738, uid = 60123},
}

function onStartup()
    local applied, skipped, missing = 0, 0, 0
    for _, fix in ipairs(FIXES) do
        local tile = Tile(fix.pos)
        if tile then
            local chest
            for _, chestId in ipairs(CHEST_IDS) do
                chest = tile:getItemById(chestId)
                if chest then
                    break
                end
            end
            if not chest and fix.itemid then
                chest = Game.createItem(fix.itemid, 1, fix.pos)
            end
            if chest then
                local uid = chest:getUniqueId()
                if uid >= 7000 and uid <= 8999 then
                    skipped = skipped + 1
                else
                    chest:setActionId(fix.aid)
                    applied = applied + 1
                end
            else
                missing = missing + 1
            end
        else
            missing = missing + 1
        end
    end
    print(string.format('[QuestChestFixups] applied=%d skipped=%d missing=%d', applied, skipped, missing))
end
