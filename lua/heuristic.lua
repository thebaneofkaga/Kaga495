local M = {}

local TheCharData = require("chardata")
local TheClassData = require("classdata")
local mapReader = require("mapReader")

function findMoves(character, map, movement)
    allPossibleMovement = {}
    finalList = {}
    round = 0;

    
    
end

function calculateScore()
    -- add cover 25

    -- add if can attack 40

    -- -- add if can hit 40

    -- -- add if can kill 45

    -- add if will get hit -25

    -- add if survivable (50/ -50)

    -- add if will win (50)

    -- add in range
    -- -- !in range 25
    
    -- -- else
    -- -- can hit 40

    -- -- get hit -25

    -- -- survivable (50 / -50)


end

function getNextCharMove(character, slotNum, map)
    move = ""
    print("running next move for slot " .. slotNum)

    terrain = {}
    terrain = TheClassData.GetClassType(character[2])
    print("loaded in terrain movement")
    -- TheCharData.tprint(map)
    findMoves(character, map, terrain)

    -- find what moves slot could take

    -- calculate score for each move

    

    return move;
end

function GroupHeuristic(tableOfCharacters)
    move = {};

    TheCharData.PrintTable(tableOfCharacters)

    for i,v in ipairs(tableOfCharacters) do
        move[i] = getNextCharMove(v)
    end


end
--[[ 
GroupHeuristic(TheCharData.PlayerUnits);
getNextCharMove(TheCharData.PlayerUnits[1]);

-- ]]


M.GroupHeuristic = GroupHeuristic;
M.getNextCharMove = getNextCharMove;

return M;