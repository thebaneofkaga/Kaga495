local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local TheActions = require("actions")
map = mapReader.map;
map = charData.addUnitsToMap(map)

--charData.tprint(map)

--charData.tprint(map[7][16])

myUnit = charData.PlayerUnits[2] --should be Marcus (11)
myWindows = TheActions.Investigate(map, myUnit)

charData.tprint(myWindows)

--myUnit = charData.PlayerUnits[4] --should be Rebecca (11)
--myScore = heuristic.calculateScore(myUnit, map)
--print("myScore: " .. myScore)

--print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, map))