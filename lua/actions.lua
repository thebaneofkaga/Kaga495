local M = {}

local TheCharData = require("chardata")
local TheTrueHit = require("truehit")
local TheVba = require("vbaF")

--parameter is the unit you want to move (cycle to find the unit based on some search)
function SelectUnit(Unit)

end

--parameters are the unit in question and the desired (X,Y) coordinates
--Note: assumes the unit can make the move (because our software decided the move was the best move)
--Note: assumes the unit is selected
function Move(Unit, LocX, LocY)
    --extract current unit (X,Y)
    myX = memory.readbyte(Unit[7])
    myY = memory.readbyte(Unit[8])

    --[[
    print("myX: " .. myX)
    print("myY: " .. myY)
    print("locX: " .. LocX)
    print("locY: " .. LocY)
    --]]

    difX = LocX - myX
    difY = LocY - myY

    absX = math.abs(difX)
    absY = math.abs(difY)

    --[[
    print("difX: " .. difX)
    print("difY: " .. difY)
    --]]
    
    --actually select the unit
    TheVba.Press("A",30)    
    --move left/right first
    for i = 1, absX, 1
    do
        if (difX < 0)
        then
            TheVba.Press("left", 60)
        else
            TheVba.Press("right", 60)
        end
    end

    --move up/down second
    for i = 1, absY, 1
    do
        if (difY < 0)
        then
            TheVba.Press("up", 60)
        else
            TheVba.Press("down", 60)
        end
    end

    TheVba.Press("A", 120)
    
end

--parameters are your unit, the weapon to use, and the (x,y) coordinates of the enemy 
--Note: assumes that the attack is optimal AND that the weapon requested is in the inventory 
--the weapon should be there because that weapon was chosen based on an investigated combat window
function Attack(Unit, Weapon, EneX, EneY)
    --press "Attack"
    TheVba.Press("A", 60)
    --select the weapon
    --assume the weapon to use isn't the first one you see (it might be though)
    notOnWeapon = true
    while(notOnWeapon)
    do
        --this is one of 3 addresses that all hold the currently "hovered over" item in this menu
        currItem = memory.readbyte(0x0203A40E) .. ""
        if(currItem == Weapon)
        then
            --now that we found the weapon we can press down and enter the combat window
            TheVba.Press("A", 60)
            --and of course, kick out of the loop
            notOnWeapon = false
        else
            --cycle down the list of items
            TheVba.Press("down", 60)
        end
    end

    --Select proper target tile
    --The cursor automatically moves to the targeted enemy, however, you can be in range of multiple enemies
    --For example, if an enemy is to the left and above you, the cursor auto places itself on the one above

    --Valid section
    --If our "dummy cursor" isn't on the requested enemy, just press right
    --We can keep pressing right until the "dummy cursor" is on the enemy tile
    --If there is only one enemy, then pressing right doesn't actually do anything (which doesn't matter)
    --If there are multiple enemies, then each right will cycle to a different enemy

    --Excluding the long bow and seige tomes (so, the realistic scenario of enemies within 1-2 range) looks like this
    --[[
                X
            X   X   X
        X   X   U   X   X
            X   X   X
                X
    --]]

    --assume that the enemy isn't selected when the cursor snaps to an enemy
    notOnEnemy = true
    while(notOnEnemy)
    do
        --these addresses hold the (x,y) coordinates of the cursor when it's snapping to an enemy
        --Note: these addresses don't update when simply moving the cursor across the screen when playing--only during this moment
        --Concern: these addresses are based on the coordinate plane with (0,0) being the top left corner--NOT (1,1) like lua!
        dumX = memory.readbyte(0x0203A480) 
        dumY = memory.readbyte(0x0203A481)
        if(dumX == EneX and dumY == EneY)
        then
            --if the coordinates match, then we found the enemy (kick out)
            notOnEnemy = false
        else 
            --otherwise, we can cycle to the next target
            --when this continues to loop, the dumX and dumY will get re-read for the next comparison
            TheVba.Press("right", 60)
        end
    end
    --the end of this loop should secure the enemy is the proper one selected

    --Confirm the combat window
    TheVba.Press("A", 60)
    --Wait for the round of combat.
    --Might need to increase this time due to level ups and such
    --240 frames seem to be a generous enough wait time for a "one time fits all" 
    --If we knew the outcome of a fight (such as a 100% guarantee to kill in one attack), we could optimize the frames
    --Caution: a level up might require additional waiting time (as it takes many frames for the level up)
    TheVba.NextInput(240)
    --By now, the cursor should be located on the unit who initiated the attack (might be relevant)
end

--parameters are the unit and the item said unit will consume
--Note: assumes that the unit already knows it has an item it wants to use
--Note: also assumes the unit also is on the optimal tile (already moved)
--Relatively important: CANTO is not accounted for in the use option, but the AI simply knows that it exists
function UseItem(Unit, Item)
    --Reminder: item value is in hex
    local itemSlotOne = 20
    local firstItem = Unit[itemSlotOne]
    local currItem = firstItem
    --Press "Item"
    TheVba.Press("A", 60)
    --Cycle until you find the item you want to use
    --The most common call will probably be "6B" (Vulnerary)
    for i = 1, 5, 1
    do
        if(Item == memory.readbyte(currItem))
        then
            --Select the item
            TheVba.Press("A", 60)
            --Confirm to use the item
            TheVba.Press("A", 60)
            return
        else
            --Reminder: Unit[21], 23, 25... are the item amounts (For example: Vulnerary has 3 uses)
            currItem = Unit[itemSlotOne + 2]
            TheVba.Press("down", 2)
        end
    end 
end

--myUnit = TheCharData.PlayerUnits[2] --should be Marcus (11)
--myUnit = TheCharData.PlayerUnits[3] --should be Lowen (11)
--eneUnit = TheCharData.EnemyUnits[6] --should be the first bandit (11)

--myUnit = TheCharData.PlayerUnits[1] --should be Lyn (P)
--myItem = 0x6b --Vulnerary
--UseItem(myUnit, myItem)

--Example Bug Below
--myUnit = TheCharData.PlayerUnits[4] --should be Florina (3)
--eneUnitOne = TheCharData.EnemyUnits[1] --should be the below bandit (3)
--eneUnitTwo = TheCharData.EnemyUnits[5] --should be the above bandit (3)
--Attack(myUnit, eneUnitOne)

--no parameters needed
--Like above, the function does not care about if a unit has Canto
function OpenDoor(Unit)
    --Opens the door (near instantly)
    TheVba.Press("A", 60)
end

--no parameters needed
--Again, Canto isn't considered
function OpenChest()
    --Giving a somewhat generous wait after opening a chest (just in case an input might get eaten)
    TheVba.Press("A", 240)
end

--parameters are the the shop itself (different shops have different items), the available gold to spend, and the item(s?) the unit want
function PurchaseItem(Shop, Gold, Item)
    --The unit itself isn't important when shopping UNLESS we decide that we won't use the convoy (not enough space to buy)
    --enter the shop
    TheVba.Press("A", 60)
    --Skip dialogue
    TheVba.Press("A", 60)
    --Select "Buy"
    TheVba.Press("A", 60)
    --TODO: Add find item in the shop
    --Issue: Cannot find the hex values of items in a given shop! (See "GetShopData()")
end

--Unknown parameters, might need to hardcode shop data
--Alternatively, don't use any shops...
function GetShopData()
    local ShopItems = {}
    --BUG: This is your convoy base! Not shop base!
    --itemBase = 0x0203A720 
    --Caution: Don't know where to find shops in memory...
    for i = 1, 100, 1
    do
        myHex = memory.readbyte(itemBase)
        print("at " .. itemBase .. " the hex is " .. myHex)
        itemBase = itemBase + 0x2
    end
end

--parameter is the unit who will be rescued (As the AI already told the moving unit the optimal location)
--Suffers from the same bug as the attack action
function Rescue(Target)

end

--assumes that a unit is already holding a unit in question
--will need to know adjacent tiles (as you cannot drop a unit on top of an enemy or terrain it cannot cross)
function Drop()

end

--no parameters needed
function Seize()
    --Seize instantly ends the chapter
    TheVba.Press("A", 60)
    --Consider adding in calls to skip post-chapter dialogue
end

--no parameters needed
function Wait()
    --simply end the units turn without taking any other actions
    --surprisingly more common than expected
    --Interesting Note: wait is always the last option to select (moving up loops the selector to the bottom)
    --If you have no items in your inventory and you are not adjacent to anyone, you might not have ANY other possible actions
    --Because of this, pressing "up" when your list of actions is just "Wait" results in an obsolete waste of 60 frames
    --But I won't optimize this
    TheVba.Press("up", 60)
    TheVba.Press("A", 60)
end

--no parameters needed
function WaitOutTheEnemy() 
    --when it's not the player's turn, you can only watch (there is no way to input anything besides soft/hard resetting your game)

    phaseBase = 0x0202BC07
    --[[
        0x00: Player Phase
        0x40: Neutral Phase
        0x80: Enemy Phase 
    --]]
    --Because you can only take control on player phase, being in the neutral phase is equivalent to enemy phase when waiting
    notMyTurn = true
    while(notMyTurn)
    do 
        hexPhase = memory.readbyte(phaseBase)
        if(hexPhase == 0x80 or hexPhase == 0x40)
        then
            --Since the only thing you can do is wait, just call our NextInput function
            print("Not my turn! Waiting 150 frames!")
            TheVba = NextInput(150)
        else
            --print("My turn! Waiting 150 frames!")
            notMyTurn = false
        end
    end
end

--no parameters needed
function GetTurnCount()
    turnBase = 0x0202BC08
    while(1)
    do
        intTurn = memory.readbyte(turnBase)
        --print("The current turn is " .. intTurn)
        TheVba.NextInput(150)
    end
end

--no parameters needed
--Note: Since different villages yield different rewards (item/gold/character), we might need to hardcode the rewards
--Caution: This could impact the inputs required when skipping dialogue and updating the map
function VisitVillage()
    TheVba.Press("A", 60)
    --Similar to opening a chest, I'm giving a fairly generous wait time
    TheVba.Press("start", 3600)
end







aCombatWindow = {
    enemyHP,
    enemyDMG, 
    enemyHIT,
    --enemyCRIT, --assuming enemy (and player) crits are 0
    enemyEffSpd,
    playerHP,
    playerDMG,
    playerHIT,
    --playerCRIT, --see above
    playerEffSpd,
    playerSelectedWeapon,
    enemyX,
    enemyY
}

--no parameters needed
--This is sort of a weird/not-so-intuitive function
--I could go out of my way and code all the equations that the game truly knows (such as the below source)
--https://serenesforest.net/blazing-sword/miscellaneous/calculations/
--I could combine the slot data with these calculations to get ahold of the combat window statistics (and have them at all times)
--ALTERNTAIVELY: I could use a handful of memory addresses that hold the CURRENT player and CURRENT enemy combat window stats
--this eliminates most (if not all) of the equations I would need to program 
--Minor Annoyance: I need to be in the combat window to read these memory addresses (after all, they are temporary)
--this function will be used to "investigate" the combat window to look at these memory addresses
--after I read those addresses, I back out to where I was beforehand
--I will then call for an attack AFTER I have investigated each combat window 
--INTENTIONAL CONCERN!!!: I don't care about the quality of the combat statistic!!! This is by design!!!
--The only purpose of this function is to populate the variables from those temporary addresses--NOT to decide if it is a good idea
function Investigate(map, Unit)
    print("entering investigate")
    myRanges = TheCharData.GetUnitRange(Unit)
    --TheCharData.tprint(myRanges)
    myWeapons = #myRanges

    --table to hold all the combat window statistics when this gets returned
    --For now, only implementing the melee adj
    local combatWindows = {}

    --have to know where I am to know what enemies are near me
    myX = memory.readbyte(Unit[7]) --Recall: horz and vert positions
    myY = memory.readbyte(Unit[8])

    --Recall: the keys for map is the row; the keys for map[row] is the col
    --Recall the range table for out of bounds 
    --Due to indexing issues, this is what each check would be for the bounds
    --[[
                                [y-1][x+1]

                    [y  ][x  ]	[y  ][x+1]	[y  ][x+2]

        [y+1][x-1]	[y+1][x  ]	[y+1][x+1]	[y+1][x+2]	[y+1][x+3]

                    [y+2][x  ]	[y+2][x+1]	[y+2][x+2]

                                [y+3][x+1]

    --]]

    local enemiesOneRange = 0
    local enemiesTwoRange = 0
    local enemiesOneOrTwoRange = 0

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
        if(adjT[2] == 2)
        then
            enemiesOneRange = enemiesOneRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is the tile directly to the right of me
    if(myX+2 > rightBound)
    then
        adjR = {}
    else 
        adjR = map[myY+1][myX+2]
        if(adjR[2] == 2)
        then
            enemiesOneRange = enemiesOneRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end
    
    --this is the tile directly below me
    if(myY+2 > botBound) 
    then
        adjB = {}
    else 
        adjB = map[myY+2][myX+1]
        if(adjB[2] == 2)
        then
            enemiesOneRange = enemiesOneRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is the tile directly to the left of me
    if(myX < leftBound)
    then
        adjL = {}
    else
        adjL = map[myY+1][myX]
        if(adjL[2] == 2)
        then
            enemiesOneRange = enemiesOneRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end 

    --below are the tiles for weapons that could attack at 2 range
    --this is 2 tiles above me
    if(myY-1 < topBound)
    then
        adjTT = {}
    else
        adjTT = map[myY-1][myX+1]
        if(adjTT[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is 1 tile up and 1 tile right
    if(myY < topBound or myX+2 > rightBound)
    then
        adjTR = {}
    else
        adjTR = map[myY][myX+2]
        if(adjTR[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is 1 tile down and 1 tile right
    if(myY+2 > botBound or myX+2 > rightBound)
    then
        adjBR = {}
    else
        adjBR = map[myY+2][myX+2]
        if(adjBR[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is 2 tiles below me
    if(myY+3 > botBound)
    then
        adjBB = {}
    else
        adjBB = map[myY+3][myX+1]
        if(adjBB[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is 1 tile to the left and 1 tile down
    if(myX < leftBound or myY+2 > botBound)
    then
        adjBL = {}
    else
        adjBL = map[myY+2][myX]
        if(adjBL[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end

    --this is 2 tiles to the left
    if(myX-1 < leftBound)
    then
        adjLL = {}
    else
        adjLL = map[myY+1][myX-1]
        if(adjLL[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end 

    --this is 1 tile to the left and 1 tile up
    if(myX < leftBound or myY < topBound)
    then
        adjTL = {}
    else
        adjTL = map[myY][myX]
        if(adjTL[2] == 2)
        then
            enemiesTwoRange = enemiesTwoRange + 1
            enemiesOneOrTwoRange = enemiesOneOrTwoRange + 1
        end
    end
    print(enemiesOneRange)
    print(enemiesTwoRange)
    --assume that on any given tile, you can't attack anything (reasonable assumption)
    canAttack = false

    --if there are ANY enemies you CAN attack, investiage their combat windows
    --Note: even enemies you can't attack are in these variables, but we'll ignore them if you can't attack them
    if(enemiesOneRange > 0 or enemiesTwoRange > 0 or enemiesOneOrTwoRange > 0)
    then
        --first check adj enemies
        if(enemiesOneRange > 0)
        then
            --check your weapons to see if you have a weapon that can attack adj enemies (both 1 / 1 or 2 ranged weapons)
            for i = 1, myWeapons, 1
            do
                --Recall the following
                --[[
                    1: 1 Range
                    2: 2 Range
                    3: 1-2 Range
                --]]
                if(myRanges[i] == 1 or myRanges[i] == 3)
                then
                    print("can Attack")
                    --I've confirmed that I -can- attack, so I know the input will happen
                    canAttack = true
                end
            end
        end

        if(enemiesTwoRange > 0)
        then
            for i = 1, myWeapons, 1
            do
                if(myRanges[i] == 2 or myRanges[i] == 3)
                then
                    print("can Attack")
                    canAttack = true
                end
            end
        end

        --by now, I should know if I can attack (based on the aformentioned bool)
        if(canAttack)
        then
            --enter the usable weapon menu
            TheVba.Press("A", 60)
        end

        --loop through each weapon that can attack (which isn't a list of all weapons in your inventory)
        --KNOWN BUG: a Paladin -can- have an iron bow in his inventory... which has a range value of 2
        --a Paladin can never use a bow in combat, but that range is still "valid"
        --SOLUTION FOR LATER: implement class weapon ranks and weapons' ranks

        --for now, assuming the usable weapon menu will be the same as your weapon list
        --NOT TRUE all the time, but for now it's good enough
        
        for i = 1, myWeapons, 1
        do
            --These addresses hold the currently hovered over item
            --[[
                0x0203A40E <- Arbitrarily chose this one
                0x0203A438
                0x0203A43A
            --]]

            local currWeapon = memory.readbyte(0x0203A40E)
            local currRange = TheCharData.GetWeaponRange(currWeapon)

            if(currRange == 1)
            then
                --enter the combat window
                TheVba.Press("A", 60)
                for j = 1, enemiesOneRange, 1
                do
                    local tempCombatWindow = {}
                    table.insert(tempCombatWindow, aCombatWindow)
                    --Grab the temp addresses and put them into a table
                    tempCombatWindow[1] = memory.readbyte(0x0203A4E2) --enemyHP
                    tempCombatWindow[2] = memory.readbyte(0x0203A4F7) --enemyDMG
                    tempCombatWindow[3] = memory.readbyte(0x0203A4D4) --enemyHIT
                    tempCombatWindow[4] = memory.readbyte(0x0203A4CE) --enemyEffSpd
                    tempCombatWindow[5] = memory.readbyte(Unit[10])   --playerHP; ironically, currHP is always here
                    tempCombatWindow[6] = memory.readbyte(0x0203A4F3) --playerDMG
                    tempCombatWindow[7] = memory.readbyte(0x0203A454) --playerHIT
                    tempCombatWindow[8] = memory.readbyte(0x0203A44E) --playerEffSpd
                    tempCombatWindow[9] = string.format("%x", memory.readbyte(Unit[20])) --player selected weapon
                    tempCombatWindow[10] = memory.readbyte(0x0203A480)
                    tempCombatWindow[11] = memory.readbyte(0x0203A481)
                    --then put them into a table of all the combat windows
                    table.insert(combatWindows, tempCombatWindow)
                    --cylce to the next enemy 
                    TheVba.Press("right", 60)
                end
                --back out of this weapon
                TheVba.Press("B", 60)
            elseif(currRange == 3)
            then
                --enter the combat window
                TheVba.Press("A", 60)
                for j = 1, enemiesOneOrTwoRange, 1
                do
                    local tempCombatWindow = {}
                    table.insert(tempCombatWindow, aCombatWindow)
                    --Grab the temp addresses and put them into a table
                    tempCombatWindow[1] = memory.readbyte(0x0203A4E2) --enemyHP
                    tempCombatWindow[2] = memory.readbyte(0x0203A4F7) --enemyDMG
                    tempCombatWindow[3] = memory.readbyte(0x0203A4D4) --enemyHIT
                    tempCombatWindow[4] = memory.readbyte(0x0203A4CE) --enemyEffSpd
                    tempCombatWindow[5] = memory.readbyte(Unit[10])   --playerHP; ironically, currHP is always here
                    tempCombatWindow[6] = memory.readbyte(0x0203A4F3) --playerDMG
                    tempCombatWindow[7] = memory.readbyte(0x0203A454) --playerHIT
                    tempCombatWindow[8] = memory.readbyte(0x0203A44E) --playerEffSpd
                    tempCombatWindow[9] = string.format("%x", memory.readbyte(Unit[20])) --player selected weapon
                    --then put them into a table of all the combat windows
                    table.insert(combatWindows, tempCombatWindow)
                    --cylce to the next enemy 
                    TheVba.Press("right", 60)
                end
                --back out of this weapon
                TheVba.Press("B", 60)
            end
            --cycle through the weapons
            for j = 1, i, 1
            do
                TheVba.Press("down", 60)
            end
        end
    end
    return combatWindows
end

function returnToStart()
    for i = 1, 5 do
        TheVba.Press("B", 60)
    end
end

M.SelectUnit = SelectUnit
M.Move = Move
M.Attack = Attack
M.UseItem = UseItem
M.OpenDoor = OpenDoor
M.OpenChest = OpenChest
M.PurchaseItem = PurchaseItem
M.Rescue = Rescue
M.Drop = Drop
M.Seize = Seize
M.Wait = Wait
M.WaitOutTheEnemy = WaitOutTheEnemy
M.GetTurnCount = GetTurnCount
M.VisitVillage = VisitVillage
M.Investigate = Investigate
M.returnToStart = returnToStart

return M