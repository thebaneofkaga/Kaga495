local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local BFS = require("2pointBFS")
local classData = require("classData")

map = mapReader.map;
map = charData.addUnitsToMap(map)

-- charData.tprint(map)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))

-- path = BFS.BFS(16,12, 25, 12,map, classData.GetClassType(memory.readword(charData.PlayerUnits[1][2])));
-- charData.tprint(path)
-- dist = BFS.getLengthOfPath(path, map, classData.GetClassType(memory.readword(charData.PlayerUnits[1][2])))
-- print(dist)
-- print(memory.readword(charData.PlayerUnits[2][2]))
moves = heuristic.findMoves(charData.PlayerUnits[2], map, classData.GetClassType( memory.readword(charData.PlayerUnits[2][2])) )


