local FIXES = {
  {x=32423, y=31591, z=15, itemid=1718, aid=1159},
  {x=32428, y=31591, z=15, itemid=1718, aid=1160},
  {x=32421, y=31594, z=15, itemid=1721, aid=1161},
  {x=32498, y=31721, z=15, itemid=3058, aid=1156},
  {x=32500, y=31721, z=15, itemid=3103, aid=1157},
  {x=32503, y=31724, z=15, itemid=3103, aid=1158},
  {x=32644, y=31614, z=6, itemid=3058, aid=1255},
  {x=32680, y=31603, z=15, itemid=385, aid=1065},
  {x=32588, y=31644, z=3, itemid=1717, aid=1075},
  {x=32588, y=31645, z=3, itemid=1717, aid=1074},
  {x=32248, y=31866, z=8, itemid=1744, aid=1225},
  {x=32180, y=31934, z=7, itemid=1718, aid=1221},
  {x=32262, y=31861, z=11, itemid=3058, aid=1207},
  {x=32497, y=31887, z=7, itemid=2720, aid=1036},
  {x=32427, y=31943, z=14, itemid=3103, aid=1137},
  {x=32460, y=31951, z=5, itemid=1717, aid=1070},
  {x=32589, y=31794, z=5, itemid=3058, aid=1046},
  {x=32636, y=31873, z=10, itemid=3058, aid=1332},
  {x=32726, y=31980, z=7, itemid=1410, aid=1226},
  {x=31983, y=32193, z=5, itemid=2725, aid=1017},
  {x=31984, y=32246, z=10, itemid=1742, aid=1031},
  {x=32005, y=32139, z=3, itemid=2103, aid=1027},
  {x=32084, y=32181, z=8, itemid=405, aid=1224},
  {x=32176, y=32132, z=9, itemid=3058, aid=1028},
  {x=32175, y=32145, z=11, itemid=3058, aid=1029},
  {x=32174, y=32149, z=11, itemid=3058, aid=1030},
  {x=32172, y=32169, z=7, itemid=2725, aid=1017},
  {x=32179, y=32224, z=9, itemid=2844, aid=1024},
  {x=32414, y=32147, z=15, itemid=1717, aid=1038},
  {x=32411, y=32155, z=15, itemid=1717, aid=1056},
  {x=32509, y=32181, z=13, itemid=3103, aid=1055},
  {x=32305, y=32254, z=9, itemid=3103, aid=1128},
  {x=32568, y=32085, z=12, itemid=3103, aid=1254},
  {x=32589, y=32097, z=14, itemid=385, aid=1039},
  {x=32652, y=32107, z=7, itemid=1290, aid=1192},
  {x=32578, y=32177, z=15, itemid=1718, aid=1209},
  {x=32514, y=32248, z=8, itemid=4367, aid=1243},
  {x=32576, y=32216, z=15, itemid=3058, aid=1057},
  {x=32219, y=32401, z=10, itemid=385, aid=1175},
  {x=32181, y=32468, z=10, itemid=4183, aid=1331},
  {x=32239, y=32471, z=10, itemid=3103, aid=1170},
  {x=32239, y=32478, z=10, itemid=3103, aid=1171},
  {x=32233, y=32491, z=10, itemid=3058, aid=1174},
  {x=32245, y=32492, z=10, itemid=2844, aid=1173},
  {x=32370, y=32265, z=12, itemid=385, aid=1142},
  {x=32256, y=32500, z=10, itemid=3058, aid=1172},
  {x=32514, y=32303, z=10, itemid=3058, aid=1037},
  {x=32800, y=31582, z=2, itemid=1718, aid=1076},
  {x=33063, y=31624, z=15, itemid=1742, aid=1051},
  {x=33084, y=31650, z=12, itemid=3103, aid=1122},
  {x=32800, y=31959, z=7, itemid=2720, aid=1208},
  {x=32813, y=31964, z=7, itemid=2720, aid=1208},
  {x=32769, y=31968, z=7, itemid=2720, aid=1153},
  {x=32868, y=31955, z=11, itemid=2720, aid=1050},
  {x=32880, y=31955, z=11, itemid=2720, aid=1154},
  {x=33182, y=31869, z=12, itemid=3058, aid=1108},
  {x=33127, y=31885, z=9, itemid=3103, aid=1083},
  {x=32775, y=32006, z=11, itemid=1744, aid=1115},
  {x=32786, y=32254, z=8, itemid=1774, aid=1119},
  {x=33327, y=32180, z=8, itemid=1742, aid=1110},
  {x=32778, y=32282, z=11, itemid=3058, aid=1124},
  {x=32814, y=32281, z=8, itemid=3058, aid=1214},
  {x=32816, y=32279, z=8, itemid=3058, aid=1213},
  {x=32817, y=32283, z=8, itemid=3103, aid=1215},
  {x=32781, y=32334, z=6, itemid=405, aid=1040},
  {x=32933, y=32495, z=7, itemid=3882, aid=1298},
  {x=33049, y=32399, z=10, itemid=1410, aid=1127},
  {x=33315, y=32277, z=11, itemid=1410, aid=1111},
  {x=33315, y=32282, z=11, itemid=1410, aid=1112},
  {x=32954, y=32695, z=8, itemid=4875, aid=1324},
  {x=33126, y=32589, z=15, itemid=1419, aid=1265},
  {x=33145, y=32663, z=15, itemid=1419, aid=1264},
  {x=33182, y=32712, z=14, itemid=1419, aid=1263},
  {x=33051, y=32774, z=14, itemid=1419, aid=1266},
  {x=33155, y=32840, z=6, itemid=1721, aid=1269},
  {x=33186, y=32903, z=11, itemid=1718, aid=1268},
  {x=33174, y=32932, z=15, itemid=1419, aid=1261},
  {x=33178, y=33013, z=14, itemid=1419, aid=1267},
  {x=33349, y=32825, z=14, itemid=1419, aid=1262},
}

function onStartup()
  local applied = 0
  local missing = 0
  local fallback = 0
  for i = 1, #FIXES do
    local f = FIXES[i]
    local tile = Tile(Position(f.x, f.y, f.z))
    if tile then
      local item = tile:getItemById(f.itemid)
      if not item then
        local items = tile:getItems()
        if items and items[1] then
          item = items[1]
          fallback = fallback + 1
        end
      end
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
  print(string.format("[TvpAidSyncNonchest1000_2000] applied=%d missing=%d fallback=%d", applied, missing, fallback))
  return true
end
