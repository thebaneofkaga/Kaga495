local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local BFS = require("2pointBFS")
local classData = require("classData")
local TheActions = require("actions")


map = mapReader.map;
map = charData.addUnitsToMap(map)

-- charData.tprint(map)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))


myUnit = charData.PlayerUnits[2] --should be Marcus (11)
TheActions.Attack(myUnit, "3", 7, 7)
-- myWindows = TheActions.Investigate(map, myUnit)

-- charData.tprint(myWindows)

--myUnit = charData.PlayerUnits[4] --should be Rebecca (11)
--myScore = heuristic.calculateScore(myUnit, map)
--print("myScore: " .. myScore)

--path = BFS.goalPath(16,12, 4, 8,map, classData.GetClassType(memory.readword(charData.PlayerUnits[1][2])));
--charData.tprint(path)
--dist = BFS.getLengthOfPath(path, map, classData.GetClassType(memory.readword(charData.PlayerUnits[1][2])))
--print(dist)
-- print(memory.readword(charData.PlayerUnits[2][2]))
-- moves = heuristic.findMoves(charData.PlayerUnits[2], map, classData.GetClassType( memory.readword(charData.PlayerUnits[2][2])) )
-- tprint(moves)