local M = {}

--[[
    Current Task: Display class as string of class name by using classdata.lua

    TODO: See how enemy reinforcements affect slot visualization
--]]

local TheClassData = require("classdata")

--[[
Player and Enemy Units is a table of Slots
Slots are a table of values
Values are indexed as ints and not as strings (for easier iterations)
Boss mimics the structure as well, although, it's size is 1 Slot (because there's only 1 boss)
--]]

PlayerUnits = {}
EnemyUnits = {}
Boss = {}

--First Addresses for Unit Slots. These will point to slot 1 (main lord)
--Unless NOTED, these have a length of a byte
PortraitBase = 0x0202BD50 --NOTE: Word
ClassBase = 0x0202BD54 --NOTE: Word
LevelBase = 0x0202BD58
ExpBase = 0x0202BD59

TurnStatusBase = 0x0202BD5C
--[[
00: Not Moved
10: Rescued Someone, but hasn't moved
42: Moved/Grayed out
52: Moved/Grayed out + has rescued someone
63: Was rescued by someone and is carried

05: Invisible? Dead? Unknown!
--]]

HiddenStatusBase = 0x0202BD5D
--[[
00: No effect
10: Consumed Afa's Drops
20: Will drop last item on death (green flash)
--]]

--Location on Map
HorzBase = 0x0202BD60
VertBase = 0x0202BD61

--Unit Stats (raw)
HPMaxBase = 0x0202BD62
HPCurBase = 0x0202BD63
StrBase = 0x0202BD64
SklBase = 0x0202BD65
SpdBase = 0x202BD66
DefBase = 0x0202BD67
ResBase = 0x0202BD68
LukBase = 0x0202BD69

--Bonuses provided by one time use consumables
ConBonusBase = 0x0202BD6A
RescueBase = 0x0202BD6B
MovBonusBase = 0x0202BD6D

--Current Equipment
Item1TypeBase = 0x0202BD6E
Item1QuantityBase = 0x0202BD6F
Item2TypeBase = 0x0202BD70
Item2QuantityBase = 0x0202BD71
Item3TypeBase = 0x0202BD72
Item3QuantityBase = 0x0202BD73
Item4TypeBase = 0x0202BD74
Item4QuantityBase = 0x0202BD75
Item5TypeBase = 0x0202BD76
Item5QuantityBase = 0x0202BD77

--Weapon Rank as an INT. Once it reaches a benchmark, raise rank
SwordSkillBase = 0x0202BD78
LanceSkillBase = 0x0202BD79
AxeSkillBase = 0x0202BD7A
BowSkillBase = 0x0202BD7B
StaffSkillBase = 0x0202BD7C
AnimaSkillBase = 0x0202BD7D
LightSkillBase = 0x0202BD7E
DarkSkillBase = 0x0202BD7F

StatusEffectBase = 0x0202BD80
--[[
Effect for B turns
0B: No effect
1B: Poison
2B: Sleep
3B: Silence
4B: Berserk
5B: Attack Boost (Fila's Might)
6B: Defense Boost (Ninis' Grace)
7B: Critical Boost (Thor's Ire)
8B: Avoid Boost (Set's Litany)
--]]

Support1Base = 0x0202BD82
Support2Base = 0x0202BD83
Support3Base = 0x0202BD84
Support4Base = 0x0202BD85
Support5Base = 0x0202BD86
Support6Base = 0x0202BD87
Support7Base = 0x0202BD88
--[[
00-4F: No support
50: C rank available
51-9F: C rank
A0: B rank available
A1-EF: B rank
F0: A rank available
F1: A rank
--]]

Slot = {}
Elements = 45
--[[
Slot["Portrait"] = PortraitBase
Slot["Class"] = ClassBase
Slot["Level"] = LevelBase
Slot["Exp"] = ExpBase
Slot["TurnStatus"] = TurnStatusBase
Slot["HiddenStatus"] = HiddenStatusBase
Slot["Horz"] = HorzBase
Slot["Vert"] = VertBase
Slot["HPMax"] = HPMaxBase
Slot["HPCur"] = HPCurBase
Slot["Str"] = StrBase
Slot["Skl"] = SklBase
Slot["Spd"] = SpdBase
Slot["Def"] = DefBase
Slot["Res"] = ResBase
Slot["Luk"] = LukBase
Slot["ConBonus"] = ConBonusBase
Slot["Rescue"] = RescueBase
Slot["MovBonus"] = MovBonusBase
Slot["Item1Type"] = Item1TypeBase
Slot["Item1Quantity"] = Item1QuantityBase
Slot["Item2Type"] = Item2TypeBase
Slot["Item2Quantity"] = Item2QuantityBase
Slot["Item3Type"] = Item3TypeBase
Slot["Item3Quantity"] = Item3QuantityBase
Slot["Item4Type"] = Item4TypeBase
Slot["Item4Quantity"] = Item4QuantityBase
Slot["Item5Type"] = Item5TypeBase
Slot["Item5Quantity"] = Item5QuantityBase
Slot["SwordSkill"] = SwordSkillBase
Slot["LanceSkill"] = LanceSkillBase
Slot["AxeSkill"] = AxeSkillBase
Slot["BowSkill"] = BowSkillBase
Slot["StaffSkill"] = StaffSkillBase
Slot["AnimaSkill"] = AnimaSkillBase
Slot["LightSkill"] = LightSkillBase
Slot["DarkSkill"] = DarkSkillBase
Slot["StatusEffect"] = StatusEffectBase
Slot["Support1"] = Support1Base
Slot["Support2"] = Support2Base
Slot["Support3"] = Support3Base
Slot["Support4"] = Support4Base
Slot["Support5"] = Support5Base
Slot["Support6"] = Support6Base
Slot["Support7"] = Support7Base
--]]
--Note: Because of visual appearance (ordering), we're going with int indexes

Slot = {
    PortraitBase, 
    ClassBase,
    LevelBase,
    ExpBase,
    TurnStatusBase,
    HiddenStatusBase,
    HorzBase,
    VertBase,
    HPMaxBase,
    HPCurBase,
    StrBase,
    SklBase,
    SpdBase,
    DefBase,
    ResBase,
    LukBase,
    ConBonusBase,
    RescueBase,
    MovBonusBase,
    Item1TypeBase, 
    Item1QuantityBase,
    Item2TypeBase, 
    Item2QuantityBase, 
    Item3TypeBase, 
    Item3QuantityBase, 
    Item4TypeBase, 
    Item4QuantityBase, 
    Item5TypeBase, 
    Item5QuantityBase,
    SwordSkillBase, 
    LanceSkillBase, 
    AxeSkillBase, 
    BowSkillBase, 
    StaffSkillBase, 
    AnimaSkillBase, 
    LightSkillBase, 
    DarkSkillBase, 
    StatusEffectBase,
    Support1Base, 
    Support2Base, 
    Support3Base,
    Support4Base, 
    Support5Base, 
    Support6Base, 
    Support7Base
}

--[[
Some Math Notes
Slot N+1 - Slot N = 0x48
Slot2 Value = Slot1 Value + 0x48

Players have a max slot of 16 units 
Enemies have a max slot of 46 units (excluding the boss)
(Enemy Boss Portrait - Slot 16 Support7) / 0x48 = 46

ESlot 1 is offset by 0x11B8 from Slot 1
ESlot1 Portrait - Slot1 Portrait = 0x11B8

Boss is offset by 0x1170 from Slot 1
Boss Portrait - Slot 1 Portrait = 0x1170

Break Loops on first slot Portrait 0000 (no need to read in unused memory)
--]]

MaxSlotsPlayer = 16
MaxSlotsEnemy = 46

--Player slots will start at 1 by design...
table.insert(PlayerUnits, Slot)

--Function to generate Enemy Slot 1 from Player Slot 1 by its offset
function ConvertToESlot(Slot)
    local ESlot = {}
    for key, value in pairs(Slot)
    do
        ESlot[key] = Slot[key] + 0x11B8
    end
    return ESlot
end

ESlot = ConvertToESlot(Slot)
table.insert(EnemyUnits, ESlot)

--Similarly, the generate the boss
--Consider: Most bosses are stationary (effectively 0 movement), but a few do (this might affect the heuristic)
function ConvertToBoss(Slot)
   local Boss = {}
   for key, value in pairs(Slot)
   do
       Boss[key] = Slot[key] + 0x1170
   end
   return Boss
end

Boss1 = ConvertToBoss(Slot)
table.insert(Boss, Boss1)

--In terms of memory, this is the quick and dirty decimal representation 
function QuickPrint(T)
    for i,v in ipairs(T) 
    do 
        print(i,v) 
    end 
end

--Source: https://gist.github.com/hashmal/874792

--An interesting print function I found for Lua
function tprint (tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            tprint(v, indent+1)
        else
            print(formatting .. v)
        end
    end
end


--Displays the read memory values
function PrintTable(T)
    for index, data in ipairs(T)
    do
        print(index)
        for key, value in pairs(data) 
        do 
            --[[
                For legacy, I left in the comment that the first key is for the portait
                When an enemy unit dies, the portrait gets set to 0, but the rest of the slot data remains (for whatever reason)
                There might be a corner case where the code below could be optimized by checking for a portrait with a value of 0
                Currently, there is no testing on enemy reinforcement and its effects on the slot data
                Possibility 1: New reinforcements are appended to the next completely unused slot
                *: This "caps" the max number of enemy units on chapters that do have reinforcements
                *: This could be a result of limited technology at the time
                Possibility 2: New reinforcements replace slots that have a portrait value of 0
                *: This recycles memory, which would be optimal, but like above, might not have been implemented due to technology
            --]]
            if(key == 2) --1: "Portrait", 2: "Class"
            then 
                value = memory.readword(value)
                if(key == 2 and value == 0x0000)
                then
                    print('\t', "No more units here!")
                    return
                end
            else
                value = memory.readbyte(value) 
            end
            value = string.format("%x", value)
            print('\t', key, value)
            
            --testing displaying terrain data
            --[[
            if(key == 2)
            then
                print("This is the unit's terrain data based on the class " .. value)
                thishex = TheClassData.GetClassType(value)
                tprint(thishex)
            end
            --testing ends here
            --]]
        end
    end
end

--Only Player Slot 1 is actually hardcoded, but this will allow you to populate the data structure holding all Slots
function Populate(PlayerOrEnemySlots, MaxSlots, Elements, Slot)
    local newoffset = 0
    for i = 2, MaxSlots, 1
    do
        local tempSlot = {}
        table.insert(PlayerOrEnemySlots, tempSlot)
        for j = 1, Elements, 1
        do
            newoffset = 72 * (i-1)
            newval = Slot[j] + newoffset
            table.insert(tempSlot, newval)
        end
    end
    return PlayerOrEnemySlots
end

PlayerUnits = Populate(PlayerUnits, MaxSlotsPlayer, Elements, Slot)
EnemyUnits = Populate(EnemyUnits, MaxSlotsEnemy, Elements, ESlot)
--QuickPrint(PlayerUnits)
--QuickPrint(EnemyUnits)
--PrintTable(PlayerUnits)
--PrintTable(EnemyUnits)

function DisplayAllUnits(PlayerUnits, EnemyUnits, Boss)
    --display players
    print("Player Units")
    PrintTable(PlayerUnits)
    --display enemies
    print("Enemy Units")
    PrintTable(EnemyUnits)
    --display boss
    print("Boss Unit")
    PrintTable(Boss)
end

--Caution: This starts coordinates at (1,1) in the top left corner
--The true memory of the game starts at (0,0) in the top left corner
function addUnitsToMap(map)
    for i,v in ipairs(PlayerUnits) do
        print(memory.readbyte(v[8]) .. ", " .. memory.readbyte(v[7]) )
        if ( memory.readword(v[2]) ~= 0x0000) then
            map[ memory.readbyte(v[8]) + 1 ][ memory.readbyte(v[7]) + 1][2] = 1
        else
            print("no more units")
            break;
        end
    end
    for i,v in ipairs(EnemyUnits) do
        print(memory.readbyte(v[8]) .. ", " .. memory.readbyte(v[7]) )
        if ( memory.readword(v[2]) ~= 0x0000) then
            map[ memory.readbyte(v[8]) + 1 ][ memory.readbyte(v[7]) + 1][2] = 2
        else
            print("no more units")
            break;
        end
    end
    for i,v in ipairs(Boss) do
        print(memory.readbyte(v[8]) .. ", " .. memory.readbyte(v[7]) )
        if ( memory.readword(v[2]) ~= 0x0000) then
            map[ memory.readbyte(v[8]) + 1 ][ memory.readbyte(v[7]) + 1][2] = 3
        else
            print("no more units")
            break;
        end
    end
    -- tprint(map)
    return map;
end

--DisplayAllUnits(PlayerUnits, EnemyUnits, Boss)

M.PlayerUnits = PlayerUnits
M.EnemyUnits = EnemyUnits
M.Boss = Boss
M.tprint = tprint
M.PlayerUnits = PlayerUnits
M.EnemyUnits = EnemyUnits
M.Boss = Boss
M.PrintTable = PrintTable
M.addUnitsToMap = addUnitsToMap

return M