local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")
local BFS = require("2pointBFS")
local classData = require("classData")
local TheActions = require("actions")
local globals = require("globals")
local TheVBA = require("vbaF")


map = mapReader.setupMap();
map = charData.addUnitsToMap(map)

-- globals.tprint(map)

-- charData.PrintTable(charData.EnemyUnits)

-- charData.tprint(map)

map = heuristic.GroupHeuristic(charData.PlayerUnits, map)
-- TheActions.WaitOutTheEnemy()
-- TheVBA.Press("start", 3600)
-- map = heuristic.GroupHeuristic(charData.PlayerUnits, map)

-- move = heuristic.getNextCharMove(charData.PlayerUnits[2], 2, map, classData.GetClassType(memory.readword(charData.PlayerUnits[2][2])))
-- globals.tprint(move)
-- TheActions.Investigate(map, charData.PlayerUnits[2])


-- myUnit = charData.PlayerUnits[2] --should be Marcus (11)
-- TheActions.Attack(myUnit, "3", 7, 7)
-- myWindows = TheActions.Investigate(map, myUnit)

-- charData.tprint(myWindows)

-- globals.tprint(classData.GetClassType(memory.readword(charData.PlayerUnits[2][2])))
-- myUnit = charData.PlayerUnits[1] --should be Rebecca (11)
-- myScore = heuristic.calculateScore(16, 7, myUnit, map)
-- print("myScore: " .. myScore)


-- path = BFS.BFS(15,5, 8, 5,map, classData.GetClassType(memory.readword(charData.PlayerUnits[3][2])));
-- globals.tprint(path)
-- dist = BFS.getLengthOfPath(path, map, classData.GetClassType(memory.readword(charData.PlayerUnits[3][2])))
-- print(dist)
-- print(memory.readword(charData.PlayerUnits[2][2]))
-- moves = heuristic.findMoves(charData.PlayerUnits[2], map, classData.GetClassType( memory.readword(charData.PlayerUnits[2][2])) )
-- tprint(moves)