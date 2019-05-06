local M = {}

local TheCharData = require("chardata")
local TheClassData = require("classdata")
local mapReader = require("mapReader")
local TheTrueHit = require("truehit")
local BFS = require("2pointBFS")
local globals = require("globals")

function findMoves(character, map, movement)
    allPossibleMovement = {}
    finalList = {}
    round = 0;
    print("finding moves from " .. memory.readbyte(character[8]) + 1 .. ", " .. memory.readbyte(character[7]) + 1)
    -- this will automatically add all of the max distance
    -- moves. then it will add all moves in the middle that
    -- have something of interest (a forest, a fort, an enemy)
    print(movement[1])
    
    for yInc = -1* movement[1], movement[1] do
        
        for xInc = -1* movement[1], movement[1]  do
            -- if (math.abs(yInc) + math.abs(xInc) <= movement[1] )
            -- then
            print("-----------------------------------------------start-----------------------------------------------")
                print(yInc + memory.readbyte(character[8])+1 .. ", " .. xInc + memory.readbyte(character[7])+1)
                path = BFS.BFS(memory.readbyte(character[7])+1, memory.readbyte(character[8])+1,
                xInc + memory.readbyte(character[7]) + 1, yInc + memory.readbyte(character[8]) + 1,
                map, movement)
                print(BFS.getLengthOfPath(path, map, movement))
                if BFS.getLengthOfPath(path, map, movement) <= movement[1]
                -- math.abs(yInc) + math.abs(xInc) == movement[1] 
                and ( maxMovement(yInc, xInc, memory.readbyte(character[8]) + 1, memory.readbyte(character[7]) + 1, map, 
                      BFS.getLengthOfPath(path, map, movement), movement) -- BFS.getLengthOfPath(path, map, movement) == movement[1]
                or isOfInterest(yInc + memory.readbyte(character[8]) + 1, xInc + memory.readbyte(character[7]) + 1, map)) -- is worth checking out
                then
                    print("found: " .. yInc + memory.readbyte(character[8]) + 1 .. ", " .. xInc + memory.readbyte(character[7]) + 1)
                    table.insert(finalList, {yInc + memory.readbyte(character[8]) + 1, xInc + memory.readbyte(character[7]) + 1})
                end
            -- end
            print("-----------------------------------------------end--------------------------------------------------")
        end
        -- print("end of for")
    end
    print("finding moves from " .. memory.readbyte(character[8]) + 1 .. ", " .. memory.readbyte(character[7]) + 1)
    print(movement[1])

    -- tprint(finalList)
    return finalList
    
end

function maxMovement(yChange, xChange, yBase, xBase, map, pathLength, movement) 
    y = yBase + yChange
    x = xBase + xChange
    if pathLength == movement[1] then
        print(y.. ", ".. x .. "is max range")
        return true
    elseif pathLength < movement[1] then
        if  BFS.getLengthOfPath(
            BFS.BFS(xBase, yBase, xChange + xBase, yChange + yBase + globals.signOf(yChange), map, movement),
            map, movement) > movement[1]        
        then
            print(y.. ", ".. x .. "is max possible movement")
            return true
        elseif BFS.getLengthOfPath(
            BFS.BFS(xBase, yBase, xChange + xBase + globals.signOf(xChange), yChange + yBase, map, movement),
            map, movement) > movement[1] 
        then
            print(y.. ", ".. x .. "is max possible movement")
            return true
        end
    end
    return false
end

-- function notImpassible(y, x, map)
--     if(map[y][x][1] == mapReader.stringToShort["Cliff"]
--     or map[y][x][1] == mapReader.stringToShort["Peak"]
--     or map[y][x][1] == mapReader.stringToShort["---"])
--     then
--         return false
--     end

--     return true
-- end

function isOfInterest(y, x, map)
    

    if map[y][x][1] == mapReader.stringToShort["Forest"]
    or map[y][x][1] == mapReader.stringToShort["Fort"]
    then
        print(y .. ", " .. x .. " is of interest")
        return true
    end
    if y+1 <= #map and 
    (map[y+1][x][2] == 2 or map[y+1][x][2] == 3)
    then
        print(y .. ", " .. x .. " has enemy")
        return true
    elseif y-1 > 0 and 
    (map[y-1][x][2] == 2 or map[y-1][x][2] == 3)
    then
        print(y .. ", " .. x .. " has enemy")
        return true
    elseif x+1 <= #map[y] and 
    (map[y][x+1][2] == 2 or map[y][x+1][2] == 3)
    then
        print(y .. ", " .. x .. " has enemy")
        return true
    elseif x-1 > 0 and 
    (map[y][x-1][2] == 2 or map[y][x-1][2] == 3)
    then
        print(y .. ", " .. x .. " has enemy")
        return true
    end
        
    return false
end

--assumes that the character has already moved onto a tile
--for now, assuming 1 range weapons only
--need the character's slot (to know his X,Y coordinates, stats, and equipment)
--Caution: map starts at (1,1) and NOT (0,0)
function calculateScore(character, map)
    local score = 0
    -- add cover 25
    myX = memory.readbyte(character[7]); --Recall: Horz Position (Col)
    myY = memory.readbyte(character[8]); --Recall: Vert Postion (Row)
    myTerrain = map[myY+1][myX+1][1]
    print(myTerrain)

    if(myTerrain == "f")
    then
        score = score + 25
    end
    
    -- add if can attack 40

    --Due to indexing issues, this is what each check would be for the bounds
    --[[
                                [y-1][x+1]

                    [y  ][x  ]	[y  ][x+1]	[y  ][x+2]

        [y+1][x-1]	[y+1][x  ]	[y+1][x+1]	[y+1][x+2]	[y+1][x+3]

                    [y+2][x  ]	[y+2][x+1]	[y+2][x+2]

                                [y+3][x+1]

    --]]

    --Map Boundries
    topBound = 1
    rightBound = #map[1]
    botBound = #map
    leftBound = 1

    --if the tile in question is out of bounds, don't read from the table!! (it will be a nil value)
    --this is the tile directly above me
    if(myY < topBound)
    then
        adjT = {}
    else
        --if we get here, this means the tile above me is in bounds, so we can read from it
        adjT = map[myY][myX+1]
    end

    --this is the tile directly to the right of me
    if(myX+2 > rightBound)
    then
        adjR = {}
    else 
        adjR = map[myY+1][myX+2]
    end
    
    --this is the tile directly below me
    if(myY+2 > botBound) 
    then
        adjB = {}
    else 
        adjB = map[myY+2][myX+1]
    end

    --this is the tile directly to the left of me
    if(myX < leftBound)
    then
        adjL = {}
    else
        adjL = map[myY+1][myX]
    end 

    --below are the tiles for weapons that could attack at 2 range
    --this is 2 tiles above me
    if(myY-1 < topBound)
    then
        adjTT = {}
    else
        adjTT = map[myY-1][myX+1]
    end

    --this is 1 tile up and 1 tile right
    if(myY < topBound or myX+2 > rightBound)
    then
        adjTR = {}
    else
        adjTR = map[myY][myX+2]
    end

    --this is 1 tile down and 1 tile right
    if(myY+2 > botBound or myX+2 > rightBound)
    then
        adjBR = {}
    else
        adjBR = map[myY+2][myX+2]
    end

    --this is 2 tiles below me
    if(myY+3 > botBound)
    then
        adjBB = {}
    else
        adjBB = map[myY+3][myX+1]
    end

    --this is 1 tile to the left and 1 tile down
    if(myX < leftBound or myY+2 > botBound)
    then
        adjBR = {}
    else
        adjBR = map[myY+2][myX]
    end

    --this is 2 tiles to the left
    if(myX-1 < leftBound)
    then
        adjLL = {}
    else
        adjLL = map[myY+1][myX-1]
    end 

    --this is 1 tile to the left and 1 tile up
    if(myX < leftBound or myY < topBound)
    then
        adjTL = {}
    else
        adjTL = map[myY][myX]
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
    
    --Inside the combat window
    myHit = memory.readbyte(0x0203A454)
    myTrueHit = TheTrueHit.GetTrueHit(myHit)
    myHitScore = 40 * myTrueHit / 100
    score = score + myHitScore

    -- -- add if can kill 45
    --Note: This will be weighted by the myHitScore (which already factors in true hit)
    --A Fine Note: If you overkill an enemy (say, doing 21 damage to someone with 20 HP), you only do 20 damage
    --Possible Caution: Suppose you could kill an enemy on the follow up attack
    --You definitely can kill them, but you risk taking damage on the enemies attack (2nd of the 3 in total)...
    --BIG Note: You don't double with Spd, you double with EFFECTIVE Spd
    --Spd Penalty = WeaponWeight - Con; if this value is positive, it becomes 0 (can only be negative)
    --Effective Spd = Spd - Spd Penalty
    --Luckily for us, this EffSpd value is already in memory!
    --Late Game Caution: Not factoring in brave weapons (these make you attack 2x per swing (up to 4x))
    mySpd = memory.readbyte(0x0203A44E)
    enemySpd = memory.readbyte(0x0203A4CE)

    myDamage = memory.readbyte(0x0203A4F3)

    if(mySpd >= (enemySpd + 4))
    then
        myDamage = myDamage * 2
    end

    enemyHP = memory.readbyte(0x0203A4E2)
    if(myDamage >= enemyHP)
    then
        score = score + 45 * myTrueHit / 100
    end

    -- add if will get hit -25
    --Note: Similar to your hit rate, this value will be a percentage of the enemy hit rate
    --Note: A unit who has a 2 range weapon attacked at 1 range has a hit rate of -1 (-- on the combat window)
    enemyHit = memory.readbyte(0x0203A4D4)
    enemyDmg = memory.readbyte(0x0203A4F7)
    if(enemyHit > 0 and enemyDmg > 0)
    then
        enemyTrueHit = TheTrueHit.GetTrueHit(enemyHit)
    else 
        enemyTrueHit = 0
    end

    score = score - 25 * enemyTrueHit / 100

    -- add if survivable (50/ -50)
    --This will be a simple check to see if dying is in the realm of possibility
    --By design, if there is a non-zero chance of displayed hit that will kill the player unit, this gets full -50
    --Conversely, if there is a zero chance of dying, you get the full +50
    --We wanted to make some numerical weight to remove gambling--even if gambling is truly the best move
    --Note: the enemy potentially doubles here, but it's likely that it would not happen
    myCurHP = memory.readbyte(character[10])

    if(enemySpd >= (mySpd + 4))
    then
        enemyDmg = enemyDmg * 2
    end

    if(enemyDmg >= myCurHP)
    then
        score = score - 50
    else
        score = score + 50
    end

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
    moves = {}
    terrain = {}
    terrain = TheClassData.GetClassType(character[2])
    print("loaded in terrain movement")
    -- TheCharData.tprint(map)
    moves = findMoves(character, map, terrain)

    -- just for testing, remove later
    calculateScore()
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
M.findMoves = findMoves;

M.calculateScore = calculateScore;

return M;