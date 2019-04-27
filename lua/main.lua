local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local BFS = require("2pointBFS")
map = mapReader.map;
map = charData.addUnitsToMap(map)

charData.tprint(map)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))

BFS.BFS(1,1,5,5,map);


