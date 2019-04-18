local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
map = mapReader.map;
map = charData.addUnitsToMap(map)

--charData.tprint(map)

--charData.tprint(map[7][16])

myUnit = charData.PlayerUnits[2] --should be Marcus (11)
heuristic.calculateScore(myUnit, map)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))