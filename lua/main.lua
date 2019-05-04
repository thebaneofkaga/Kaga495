local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local BFS = require("2pointBFS")
local classData = require("classData")

map = mapReader.map;
map = charData.addUnitsToMap(map)

-- charData.tprint(map)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))

-- path = BFS.BFS(16,12, 4, 8,map, classData.GetClassType(charData.PlayerUnits[1][2]));
-- charData.tprint(path)
-- dist = BFS.getLengthOfPath(path, map, classData.GetClassType(charData.PlayerUnits[1][2]))
-- print(dist)
moves = heuristic.findMoves(charData.PlayerUnits[2], map, classData.GetClassType(charData.PlayerUnits[2][2]))


