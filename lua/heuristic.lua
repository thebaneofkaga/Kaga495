local M = {}

local TheCharData = require("chardata")
local TheClassData = require("classdata")
local mapReader = require("mapReader")
local TheTrueHit = require("truehit")
local BFS = require("2pointBFS")
local globals = require("globals")
local actions = require("actions")
local TheVBA = require("vbaF")

function findMoves(character, map, movement)
    allPossibleMovement = {}
    finalList = {}
    round = 0;
    -- print("finding moves from " .. memory.readbyte(character[8]) + 1 .. ", " .. memory.readbyte(character[7]) + 1)
    -- this will automatically add all of the max distance
    -- moves. then it will add all moves in the middle that
    -- have something of interest (a forest, a fort, an enemy)
    -- print(movement[1])
    
    for yInc = -1* movement[1], movement[1] do
        
        for xInc = -1* movement[1], movement[1]  do
            -- if (math.abs(yInc) + math.abs(xInc) <= movement[1] )
            -- then
            -- print("-----------------------------------------------start-----------------------------------------------")
                -- print("point: " .. yInc + memory.readbyte(character[8])+1 .. ", " .. xInc + memory.readbyte(character[7])+1)
                path = BFS.BFS(memory.readbyte(character[7])+1, memory.readbyte(character[8])+1,
                xInc + memory.readbyte(character[7]) + 1, yInc + memory.readbyte(character[8]) + 1,
                map, movement)
                -- print(BFS.getLengthOfPath(path, map, movement))
                if BFS.getLengthOfPath(path, map, movement) <= movement[1]
                -- math.abs(yInc) + math.abs(xInc) == movement[1] 
                and ( maxMovement(yInc, xInc, memory.readbyte(character[8]) + 1, memory.readbyte(character[7]) + 1, map, 
                      BFS.getLengthOfPath(path, map, movement), movement) -- BFS.getLengthOfPath(path, map, movement) == movement[1]
                or isOfInterest(yInc + memory.readbyte(character[8]) + 1, xInc + memory.readbyte(character[7]) + 1, map)) -- is worth checking out
                then
                    -- print("found: " .. yInc + memory.readbyte(character[8]) + 1 .. ", " .. xInc + memory.readbyte(character[7]) + 1)
                    table.insert(finalList, {yInc + memory.readbyte(character[8]) + 1, xInc + memory.readbyte(character[7]) + 1})
                end
            -- end
            -- print("-----------------------------------------------end--------------------------------------------------")
        end
        -- print("end of for")
    end
    -- print("finding moves from " .. memory.readbyte(character[8]) + 1 .. ", " .. memory.readbyte(character[7]) + 1)
    -- print(movement[1])

    -- tprint(finalList)
    return finalList
    
end

function maxMovement(yChange, xChange, yBase, xBase, map, pathLength, movement) 
    y = yBase + yChange
    x = xBase + xChange
    if pathLength == movement[1] then
        -- print(y.. ", ".. x .. "is max range")
        return true
    elseif pathLength < movement[1] then
        if  BFS.getLengthOfPath(
            BFS.BFS(xBase, yBase, xChange + xBase, yChange + yBase + globals.signOf(yChange), map, movement),
            map, movement) > movement[1]        
        then
            -- print(y.. ", ".. x .. "is max possible movement")
            return true
        elseif BFS.getLengthOfPath(
            BFS.BFS(xBase, yBase, xChange + xBase + globals.signOf(xChange), yChange + yBase, map, movement),
            map, movement) > movement[1] 
        then
            -- print(y.. ", ".. x .. "is max possible movement")
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
        -- print(y .. ", " .. x .. " is of interest")
        return true
    end
    if y+1 <= #map and 
    (map[y+1][x][2] == 2 or map[y+1][x][2] == 3)
    then
        -- print(y .. ", " .. x .. " has enemy")
        return true
    elseif y-1 > 0 and 
    (map[y-1][x][2] == 2 or map[y-1][x][2] == 3)
    then
        -- print(y .. ", " .. x .. " has enemy")
        return true
    elseif x+1 <= #map[y] and 
    (map[y][x+1][2] == 2 or map[y][x+1][2] == 3)
    then
        -- print(y .. ", " .. x .. " has enemy")
        return true
    elseif x-1 > 0 and 
    (map[y][x-1][2] == 2 or map[y][x-1][2] == 3)
    then
        -- print(y .. ", " .. x .. " has enemy")
        return true
    end
        
    return false
end
--[[
        returnCode = {
            score,
            x for move, based on 1,1
            y for move, based on 1,1
            attack / wait,
            weapon to attack with,
            enemy to attack x, based on 0,0
            enemy to attack y based on 0,0
        }
        if wait, then the last two are nil
    ]]
--assumes that the character has already moved onto a tile
--for now, assuming 1 range weapons only
--need the character's slot (to know his X,Y coordinates, stats, and equipment)
--Caution: map starts at (1,1) and NOT (0,0)
function calculateScore(x, y, character, map)
    local returnCode = {}
    --[[
        returnCode = {
            score,
            x for move, based on 1,1
            y for move, based on 1,1
            attack / wait,
            weapon to attack with,
            enemy to attack x, based on 0,0
            enemy to attack y based on 0,0
        }
        if wait, then the last two are nil
    ]]
    local score = 0
    returnCode[2] = x
    returnCode[3] = y
    -- add cover 25
    myX = x - 1; --Recall: Horz Position (Col)
    myY = y - 1; --Recall: Vert Postion (Row)
    -- myX = x - 1
    -- myY = y - 1
    myTerrain = map[myY+1][myX+1][1]
    -- print(myTerrain)

    if(myTerrain == "f" or myTerrain == "t")
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
    ------------------------------------------------------------------------------------------------------------------------
    -- needs to be changed to incorperate the various different combat windows (done)
    -- that can appear (done)
    -- need to add special case for if you can hit but do no damage (done)
    ------------------------------------------------------------------------------------------------------------------------
    --Inside the combat window (no longer in use)

    -- move to space
    actions.Move(character, x-1, y-1)
    -- investigate
    windows = actions.Investigate(map, character)
    -- return to the base space
    actions.returnToStart()
    -- find best attack window
    if not globals.empty(windows) then
        
        globals.tprint(windows)
        bestWindow = getBestWindow(windows)
        if(not globals.empty(bestWindow)) then
            -- globals.tprint(bestWindow)
            returnCode[4] = "attack"
            returnCode[5] = bestWindow[9]
            returnCode[6] = bestWindow[10]
            returnCode[7] = bestWindow[11]
            
            -- calc attack score
            myHit = bestWindow[7]
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

            myDamage = bestWindow[6]

            if(mySpd >= (enemySpd + 4))
            then
                myDamage = myDamage * 2
            end

            enemyHP = bestWindow[1]
            if(myDamage >= enemyHP)
            then
                score = score + 45 * myTrueHit / 100
            end

            -- add if will get hit -25
            --Note: Similar to your hit rate, this value will be a percentage of the enemy hit rate
            --Note: A unit who has a 2 range weapon attacked at 1 range has a hit rate of -1 (-- on the combat window)
            enemyHit = bestWindow[3]
            enemyDmg =bestWindow[2]
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
            myCurHP = bestWindow[5]

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
        
        else
            score = -999
            returnCode[4] = "wait"
        end
    
    else
        returnCode[4] = "wait"
    end
    -- add if will win (50)

    -- -- if character is a lord and the movespot is the throne
    -- -- note, this dose not check for promoted lords. need to add that 
    -- -- for continued development
    charPort = memory.readword(character[1])
    charPort = string.format("%x", charPort)
    if (charPort == "ce4c" )
    and mapReader.shortToString[map[y][x][1]] == "Throne"
    then
        score = score + 50
    end

    -- add in range
    -- -- this will look at every enemy on the field and check
    -- -- if they are able to move to the player and attack on their turn
    for i,v in ipairs(TheCharData.EnemyUnits) do
        if memory.readword(v[2]) ~= 0 then
            range = TheClassData.GetClassType(memory.readword(v[2]))
            -- print(i .. ": ")
            -- print(memory.readbyte(v[8]) + 1 .. ", " .. memory.readbyte(v[7]) + 1)
            -- print("to " .. y .. ", " .. x)
            dist = BFS.getLengthOfPath(BFS.goalPath(memory.readbyte(v[7]) + 1, 
                   memory.readbyte(v[8]) + 1, x, y, map, range ),
                   map, range)
            if dist <= range[1] then
                -- -- can hit 40

                -- -- get hit -25

                -- -- survivable (50 / -50)
            else
                -- -- !in range 25
                score = score + 25
            end
        end
        returnCode[1] = score
        return returnCode
    end

   
    
    -- -- else
    

    return score
end

function getBestWindow(windows)
    bestScore = 0
    bestIndex = 0
    globals.tprint(windows)
    for i,v in ipairs(windows) do 
        score = (TheTrueHit.GetTrueHit(v[7]) * v[6]) - (TheTrueHit.GetTrueHit(v[3]) * v[2])
        print(score)
        if(score > bestScore) then
            globals.tprint(v)
            bestScore = score
            bestIndex = i
        end
    end
    if(bsetScore == 0) then
        return {}
    end
    return windows[bestIndex]
end

function getNextCharMove(character, slotNum, map)
    move = {0}
    print("running next move for slot " .. slotNum)
    moves = {}
    terrain = {}
    terrain = TheClassData.GetClassType(memory.readword(character[2]))
    -- print("loaded in terrain movement")
    -- TheCharData.tprint(map)
    
    -- find what moves slot could take
    moves = findMoves(character, map, terrain)
    -- calculate score for each move
    for i,v in ipairs(moves) do
        tempCode = calculateScore(v[2], v[1], character, map)
        if tempCode[1] > move[1] then
            move = tempCode
        end
    end
    --     print(v[2] .. ", " .. v[1] .. ": ")
    --     tprint(tempCode)
    -- end
    

    return move;
end

function numUnits(chars)
    num = 0
    for i,v in ipairs(chars) do
        if string.format("%x", memory.readword(v[2]) ) ~= "0" then
            num = num+1
        end
    end
    return num
end

function GroupHeuristic(tableOfCharacters, map)
    local moves = {};
    slotsMoved = {};

    -- local numOfUnits = 0
    local whlieLoopCounter = 0;
    print(numUnits(tableOfCharacters))
    for i =1, 16 do
        table.insert(slotsMoved, 0)
    end
    -- TheCharData.PrintTable(tableOfCharacters)

    -- for i,v in ipairs(tableOfCharacters) do
    --     if string.format("%x", memory.readword(v[2]) ) ~= "0" then
    --         numOfUnits = numOfUnits + 1
    --         moves[i] = getNextCharMove(v, i, map)
    --         TheVBA.Press("L", 60)
    --     end
    -- end
    globals.tprint(moves)
    
   repeat -- fix this shit
        local highestScore = 0
        local slotToMove = 0
        

        for i,v in ipairs(tableOfCharacters) do
            if string.format("%x", memory.readword(v[2]) ) ~= "0" then
                if string.format("%x", memory.readbyte(v[5]) ) == "0"
                then
                    -- numOfUnits = numOfUnits + 1
                    moves[i] = getNextCharMove(v, i, map)
                    TheVBA.Press("L", 60)
                else
                    moves[i] = {0,0,0,"wait"}
                end
            end
        end
        globals.tprint(moves)
        -- get highest score
        for i,v in ipairs(moves) do
            print(v[1] .." > " .. highestScore .. "?")
            if v[1] > highestScore then
                highestScore = v[1]
                slotToMove = i
            end
        end
        -- execute move
        -- if not globals.empty(slotsMoved) then
        --     -- print(slotToMove .. " - " .. 1 .. " - " .. #slotsMoved " = " .. slotToMove - 1 - #slotsMoved)
        -- end
        for i = 1, slotToMove - 1 do 
            if slotsMoved[i] == 0 then
                TheVBA.Press("L", 30)
            end
        end
        print("move to execute slot " .. slotToMove)
        globals.tprint(moves[slotToMove])
        executeMove(tableOfCharacters[slotToMove], moves[slotToMove])
        -- insert to slotsMoved
        print("inserting into slotsMoved")
        -- table.insert(slotsMoved, slotToMove)
        slotsMoved[slotToMove] = 1;
        globals.tprint(slotsMoved)
        -- re-evaluate
        for i = slotToMove, #tableOfCharacters do
            if string.format("%x", memory.readword(tableOfCharacters[i][2]) ) ~= "0"
            -- and string.format("%x", memory.readword(tableOfCharacters[i][5])) == "0" 
            then
                print("press L")
                TheVBA.Press("L", 30)
            end
        end
        blankSpace = false
        char = tableOfCharacters[slotToMove]
        spotsLeft = 0
        spotsUp = 0

        while not blankSpace do 
            if memory.readbyte(char[7]) + 1 - spotsLeft > 0
            and map[memory.readbyte(char[8]) + 1 - spotsUp][memory.readbyte(char[7]) + 1 - spotsLeft]
            then
                -- move cursor
                TheVBA.Press("left", 60)
                -- press L
                TheVBA.Press("L", 60)
                blankSpace = true
            elseif memory.readbyte(char[8]) + 1 - spotsUp > 0
            and map[memory.readbyte(char[8]) + 1- spotsUp][memory.readbyte(char[7]) + 1 - spotsLeft]
            then
                -- move cursor
                TheVBA.Press("up", 60)
                -- press L
                TheVBA.Press("L" , 60)
                blankSpace = true
            end
            spotsLeft = spotsLeft + 1
            spotsUp = spotsUp + 1
        end
        -- print("---------------------------------------------------------------------------------")
        -- TheCharData.PrintTable(TheCharData.EnemyUnits)
        -- print("---------------------------------------------------------------------------------")
        map = mapReader.setupMap()
        map = TheCharData.addUnitsToMap(map)
        moves = {}
        -- globals.tprint(map)
        
        whlieLoopCounter = whlieLoopCounter + 1
    until whlieLoopCounter >= numUnits(tableOfCharacters)
    print("done with round")
    return map
end

function executeMove(character, turn)
    actions.Move(character, turn[2] - 1, turn[3] - 1)
    if(turn[4] == "attack") then
        actions.Attack(character, turn[5], turn[6], turn[7])
    elseif(turn[4] == "wait") then
        actions.Wait()
    else
        print("FUCK!! HOW DID WE GET HERE?!?!-----------------------------------------------")
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