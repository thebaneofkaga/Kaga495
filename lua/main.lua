local mapReader = require("mapReader")
local heuristic = require("heuristic")
local charData = require("chardata")

--charData.tprint(mapReader.map)

print(heuristic.getNextCharMove(charData.PlayerUnits[1], 1, mapReader.map))