local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
map = mapReader.map;
map = charData.addUnitsToMap(map)

charData.tprint(map)

print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))