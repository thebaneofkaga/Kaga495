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
    TheVba.Press("A", 4)    
    --move left/right first
    for i = 1, absX, 1
    do
        if (difX < 0)
        then
            TheVba.Press("left", 30)
        else
            TheVba.Press("right", 30)
        end
    end

    --move up/down second
    for i = 1, absY, 1
    do
        if (difY < 0)
        then
            TheVba.Press("up", 30)
        else
            TheVba.Press("down", 30)
        end
    end

    TheVba.Press("A", 30)
    
end

--parameters are the two units that will fight each other
--Note: assumes that the attack is optimal
function Attack(Unit, Enemy)
    --press "Attack"
    TheVba.Press("A", 30)
    --SELECT WEAPON HERE, NOT ADDED
    --Concern: Selecting the optimal weapon here should be based on our "best move" calculation?
    TheVba.Press("A", 30)
    --Select proper target tile
    --The cursor automatically moves to the targeted enemy, however, you can be in range of multiple enemies
    --For example, if an enemy is to the left and above you, the cursor auto places itself on the one above (unconfirmed)
    --While it isn't true there is an enemy directly above you, we can "assume" there is one
    --After all, we don't need to keep track of the cursor here (potentially)
    --If our "dummy cursor" isn't on the requested enemy, just press right
    --We can keep pressing right until the "dummy cursor" is on the enemy tile
    --If there is only one enemy, then pressing left doesn't actually do anything
    --If there are multiple enemies, then each left will cycle to a different one 
    
    --Concern: Need to find the actual order of tile movements (the true order)

    --Excluding the long bow and seige tomes (so, the realistic scenario of enemies within 1-2 range) looks like this
    --[[
                X
            X   X   X
        X   X   U   X   X
            X   X   X
                X
    --]]

    --This may prove to be more troublesome in it's current state, consider changing the algorithm
    dumX = memory.readbyte(Unit[7])
    dumY = memory.readbyte(Unit[8]) - 0x1
    eneX = memory.readbyte(Enemy[7])
    eneY = memory.readbyte(Enemy[8])
    
    print("Initial State")
    print("dumX: " .. dumX)
    print("dumY: " .. dumY)
    print("eneX: " .. eneX)
    print("eneY: " .. eneY)

    cursorNotOnEnemy = true --assume it isn't on the enemy, but we'll check it first anyway
    searchAttempt = 0

    --VERY IMPORTANT BUG
    --assumes clockwise cursor rotations (NOT ACCURATE)
    while(cursorNotOnEnemy)
    do
        if(dumX == eneX and dumY == eneY)
        then
            print("found the enemy")
            cursorNotOnEnemy = false
        else
            TheVba.Press("right", 30)
            if(searchAttempt == 0)
            then 
                --dummy is on the right adjacent tile
                dumX = dumX + 0x1
                dumY = dumY + 0x1
                searchAttempt = 1
                print("Should be the right tile")
                print("dumX: " .. dumX)
                print("dumY: " .. dumY)
                print("eneX: " .. eneX)
                print("eneY: " .. eneY)
            elseif(searchAttempt == 1)
            then
                --dummy is on the bottom adjacent tile
                dumX = dumX - 0x1
                dumY = dumY + 0x1
                searchAttempt = 2
                print("Should be the bottom tile")
                print("dumX: " .. dumX)
                print("dumY: " .. dumY)
                print("eneX: " .. eneX)
                print("eneY: " .. eneY)
            elseif(searchAttempt == 2)
            then
                --dummy is on the left adjacent tile
                dumX = dumX - 0x1
                dumY = dumY - 0x1
                searchAttempt = 3 --technically unusued as of now
                print("Should be the left tile")
                print("dumX: " .. dumX)
                print("dumY: " .. dumY)
                print("eneX: " .. eneX)
                print("eneY: " .. eneY)
                --by now, the dummy has rotated around the unit
                --until full implementation with accurate rotation, this shell will do for now
            end
        end
    end
    --the end of this loop should secure the enemy is the proper one selected

    --Confirm the combat window
    TheVba.Press("A", 30)
    --Wait for the round of combat.
    --Might need to increase this time due to level ups and such
    --240 frames seem to be a generous enough wait time for a "one time fits all" 
    --If we knew the outcome of a fight (such as a 100% guarantee to kill in one attack), we could optimize the frames
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
    TheVba.Press("A", 30)
    --Cycle until you find the item you want to use
    --The most common call will probably be "6B" (Vulnerary)
    for i = 1, 5, 1
    do
        if(Item == memory.readbyte(currItem))
        then
            --Select the item
            TheVba.Press("A", 30)
            --Confirm to use the item
            TheVba.Press("A", 30)
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
    TheVba.Press("A", 30)
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
    TheVba.Press("A", 30)
    --Skip dialogue
    TheVba.Press("A", 30)
    --Select "Buy"
    TheVba.Press("A", 30)
    --TODO: Add find item in the shop
    --Issue: Cannot find the hex values of items in a given shop! (See "GetShopData()")
end

--Returns only 0s on reading
--Bug: the itemBase is not the proper location in memory (perhaps?)
function GetShopData()
    local ShopItems = {}
    itemBase = 0x0203A720
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
    TheVba.Press("A", 30)
    --Consider adding in calls to skip post-chapter dialogue
end

--no parameters needed
function Wait()
    --simply end the units turn without taking any other actions
    --surprisingly more common than expected
    --Interesting Note: wait is always the last option to select (moving up loops the selector to the bottom)
    --If you have no items in your inventory and you are not adjacent to anyone, you might not have ANY other possible actions
    --Because of this, pressing "up" when your list of actions is just "Wait" results in an obsolete waste of 30 frames
    --But I won't optimize this
    TheVba.Press("up", 30)
    TheVba.Press("A", 30)
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

    while(1)
    do 
        hexPhase = memory.readbyte(phaseBase)
        if(hexPhase == 0x80 or hexPhase == 0x40)
        then
            --Since the only thing you can do is wait, just call our NextInput function
            print("Not my turn! Waiting 150 frames!")
            TheVba = NextInput(150)
        else
            --print("My turn! Waiting 150 frames!")
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

return M