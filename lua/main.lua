local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local BFS = require("2pointBFS")
map = mapReader.map;
map = charData.addUnitsToMap(map)

-- charData.tprint(map)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))

path = BFS.BFS(16,12, 4, 8,map);
charData.tprint(path)

