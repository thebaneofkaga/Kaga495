local M = {}

local TheCharData = require("chardata")
local TheClassData = require("classdata")
local mapReader = require("mapReader")

function findMoves(character, map, movement)
    allPossibleMovement = {}
    finalList = {}
    round =0;

    while round <= movement[1] do
        
    end
    
end

--assumes that the character has already moved onto a tile
--for now, assuming 1 range weapons only
--need the character's slot (to know his X,Y coordinates, stats, and equipment)
--Caution: map starts at (1,1) and NOT (0,0)
function calculateScore(character, map)
    score = 0
    -- add cover 25
    myX = memory.readbyte(character[7]); --Recall: Horz Position (Col)
    myY = memory.readbyte(character[8]); --Recall: Vert Postion (Row)
    myTerrain = map[myY+1][myX+1][1]
    print(myTerrain)

    if(myTerrain == "")
    then
        score = score + 25
    end
    
    -- add if can attack 40
    --Map Boundries
    topBound = 1
    rightBound = #map[1]
    botBound = #map
    leftBound = 1

    --if the tile above me is out of bounds, don't read from the table!! (it will be a nil value)
    if(myX+1 < topBound)
    then
        adjT = {}
    else
        --if we get here, this means the tile above me is in bounds, so we can read from it
        adjT = map[myY][myX+1];
    end

    if(myX+2 > rightBound)
    then
        adjR = {}
    else 
        adjR = map[myY+1][myX+2]
    end
    
    if(myY+2 > botBound) 
    then
        adjB = {}
    else 
        adjB = map[myY+2][myX+1]
    end

    if(myY+1 < leftBound)
    then
        adjL = {}
    else
        adjL = map[myY+1][myX]
    end 

    --the adj tile at key 2 is the int value associated with what is on that tile
    --Recall: 0 is nobody, 1 is player unit, 2 is enemy unit...
    --Caution: Not accounting for boss attack adjX[2] == 3 because that might have a different score    
    if(adjT[2] == 2 or adjR[2] == 2 or adjB[2] == 2 or adjL[2] == 2)
    then
        score = score + 40
    end
    
    -- -- add if can hit 40
    --Note: all units will get some portion of this 40 points. You get a % of this 40 dependent on the hit rate! (80% hit gets you 32 points)
    --Note: Our AI knows about the true hit mechanic, thus, will likely score better here (and better in "getting hit")

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

    return score
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

M.calculateScore = calculateScore;

return M;