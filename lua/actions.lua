local M = {}

local TheCharData = require("chardata")
local TheTrueHit = require("truehit")
local TheVba = require("vba")

--buttons = TheVba.buttons

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

    print("myX: " .. myX)
    print("myY: " .. myY)
    print("locX: " .. LocX)
    print("locY: " .. LocY)

    difX = LocX - myX
    difY = LocY - myY

    absX = math.abs(difX)
    absY = math.abs(difY)

    print("difX: " .. difX)
    print("difY: " .. difY)
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
        if (difY > 0)
        then
            TheVba.Press("up", 30)
        else
            TheVba.Press("down", 30)
        end
    end
    
end

--myUnit = TheCharData.PlayerUnits[2] --Should be Marcus

--TheCharData.tprint(myUnit)
--Move(myUnit, 0xf, 0x6)

--parameters are the two units that will fight each other
function Attack(Unit, Enemy)

end

--parameters are the unit and the item said unit will consume
--Note: assumes that the unit already knows it has an item it wants to use
--Note: also assumes the unit also is on the optimal tile (already moved)
function UseItem(Unit, Item)
    
end

--parameter is simply the unit who will open the door 
function OpenDoor(Unit)

end

--parameter is simply the unit who will open the chest
function OpenChest(Unit)

end

--parameters are the unit who is shopping, the shop itself (different shops have different items), and the available gold to spend
function PurchaseItem(Unit, Shop, Gold)

end

--parameters are the unit who rescues and will be rescued
function Rescue(Unit, Target)

end

--parameter is the unit holding someone
function Drop(Unit)

end

--no parameters needed since the only person who can seize will be the main lord (Unit Slot 1)
function Seize()

end

M.Move = Move
M.Attack = Attack
M.UseItem = UseItem
M.OpenDoor = OpenDoor
M.OpenChest = OpenChest
M.PurchaseItem = PurchaseItem
M.Rescue = Rescue
M.Drop = Drop
M.Seize = Seize

return M