local M = {}

--[[
TODO: Account for weather effects. 
Source: https://serenesforest.net/blazing-sword/miscellaneous/weather/
--]]

--[[
    Notes On How to Require
    1. Declare a local table (e.g. call it "M")
    2. Tag all functions in the format below
    *: M.GetClassType = GetClassType
    3. Return M
--]]

--[[
While it's true that you can extract the most important data from the slot, the character's class has some required info
For example, we need to know a character's movement, which is based on class.
In addition, this lua script will account for terrain (which reflects in movement)
In short, the number of tiles a unit can move will be the following: Mov - TerrainPenalty
--]]

--[[
Each class will be represented as a table. 
Index 1 is the default class movement
Index 2 is the table of terrain data. Terrain affects classes differently, hence the need for this.
--]]

--[[
Source: https://serenesforest.net/blazing-sword/classes/terrain-data/

Terrain["Type"] = {Def, Avoid, Heal, Move Cost} --Additional Data
Move Costs of 999 simulates an uncrossable tile (could be any amount > 10)
Note: Fliers cost is always 1 regardless of terrain (assuming the terrain is crossable) with the exception of weather effects...
--]]

--Caution: Not sure if the source is 100% accurate and/or I might have mistyped some values. There may be a bug here.
Terrain = {}
Terrain["---"] = {0, 0, 0, 999} --cannot cross
Terrain["Arena"] = {0, 10, 0, 1}
Terrain["Bridge"] = {0, 0, 0, 1}
Terrain["Cliff"] = {0, 0, 0, 1} --only flying units
Terrain["Deck"] = {0, 0, 0, 1}
Terrain["Desert"] = {0, 5, 0, 2} --different per class
Terrain["Door"] = {0, 0, 0, 999} --cannot cross, key turns it to a floor
Terrain["Fence"] = {0, 0, 0, 1} --only flying units
Terrain["Floor"] = {0, 0, 0, 1}
Terrain["Forest"] = {1, 20, 0, 2} --cost 3 for knights
Terrain["Fort"] = {2, 20, 0.20, 2}
Terrain["Gate"] = {2, 20, 0.10, 1}
Terrain["House"] = {0, 10, 0 , 1}
Terrain["Lake"] = {0, 10, 0, 3} --only flying and pirates
Terrain["Mountain"] = {1, 30, 0, 4} --different per class
Terrain["Peak"] = {2, 40, 0, 4} --only flying and bandits
Terrain["Pillar"] = {1, 20, 0, 2} --3 for knights, nomads and nomadic troopers
Terrain["Plain"] = {0, 0, 0, 1}
Terrain["River"] = {0, 0, 0, 5} --different per class
Terrain["Road"] = {0, 0, 0, 1}
Terrain["Ruins"] = {0, 10, 0, 1}
Terrain["Ruins (Village)"] = {0, 0, 0, 2}
Terrain["Sand"] = {0, 5, 0, 1}
Terrain["Sea"] = {0, 10, 0, 2} --only flying and pirates
Terrain["Shop"] = {0, 10, 0, 1}
Terrain["Snag"] = {0, 0, 0, 1} --only flying units, can be attacked to make a bridge
Terrain["Stairs"] = {0, 0, 0, 1}
Terrain["Throne"] = {2, 20, 0.10, 1} --restores conditions, res+5 (Note: res+5 doesn't matter for movement, but might matter for our heuristics)
Terrain["Village"] = {0, 10, 0, 1}
Terrain["Wall"] = {0, 0, 0, 999} --cannot cross
Terrain["Wall (Weak)"] = {0, 0, 0, 999} --cannot cross, can attack to form floor

--Relatively Important Note: The above source for terrain doesn't include certain classes under "Foot": Mercenary, Myrmidon, Archer, Soldier, Dancer, and Bard (all 5 Mov)

--Source for the class hex: https://gamefaqs.gamespot.com/gba/468480-fire-emblem/faqs/31542

--Parameter is a string of the hex value for a given class (see from chardata where to get it). Returns a table. Key1 = Mov. Key2 = Terrain table (catered to its class).
function GetClassType(myClass)
    defaultMov = 5 --this is the standard movement of an unpromoted unit
    classRange = {defaultMov, Terrain}
    myClass = string.format("%x", myClass)
    print("class value of: " .. myClass)
    --"Foot" units
    --[[
        Each class, according to the slot data, comes in the form of 0xABCD. 
        Note: For Lua, if the least significant byte is a zero, then it is dropped in the formatted string. Eliwood's class hex would be "1b0"
        01B0: Lord (Eliwood)
        0204: Lord (Lyn)
        0258: Lord (Hector)
        03FC: Blade Lord
        04A4: Mercenary
        054C: Hero (Male)
        05A0: Hero (Female)
        05F4: Myrmidon (Male)
        0648: Myrmidon (Female)
        069C: Swordmaster (Male)
        06F0: Swordmaster (Female)
        093C: Archer (Male)
        0990: Archer (Female)
        09E4: Sniper (Male)
        0A38: Sniper (Female)
        13BC: Soldier
        150C: Thief (Male)
        1560: Thief (Female)
        154B: Assassin
        165C: Dancer
        16B0: Bard
    --]]
    if myClass == "1b0" or myClass == "204" or myClass == "258" or myClass == "3fc" or myClass == "4a4" or myClass == "54c" or myClass == "5a0" or myClass == "5a4" or myClass == "54c" or myClass == "5a0" or myClass == "5f4" or myClass == "648" or myClass == "69c" or myClass == "6f0" or myClass == "93c" or myClass == "990" or myClass == "9e4" or myClass == "a38" or myClass == "13bc" or myClass == "150c" or myClass == "1560" or myClass == "154b" or myClass == "165c" or myClass == "16b0"
    then
        --set movement values if they aren't the default movement 
        if myClass == "3fc" or myClass == "54c" or myClass == "5a0" or myClass == "69c" or myClass == "6f0" or myClass == "9e4" or myClass == "a38" or myClass == "150c" or myClass == "1560" or myClass == "154b"
        then
            classRange[1] = 6
        end
        --set any terrain impedements based on the type (in this case, "Foot")
        --Recall: 4th index is the cost to move over the terrain in question. 999 is arbitrarily set high to simulate "can't cross"
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Peak"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Armor" units
    --[[
        0450: Great Lord
        07EC: Knight (Male)
        0840: Knight (Female)
        0894: General (Male)
        08E8: General (Female)
    --]]
    if myClass == "450" or myClass == "7ec" or myClass == "840" or myClass == "894" or myClass == "8e8"
    then
        if myClass == "7ec" or myClass == "840"
        then
            classRange[1] = 4
        end
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 3
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 999
        classRange[2]["Peak"][4] = 999
        classRange[2]["River"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Knight A" units
    --[[
        0E7C: Cavalier (Male)
        0ED0: Cavalier (Female)
        0FCC: Troubadour
    --]]
    if myClass == "e7c" or myClass == "ed0" or myClass == "fcc"
    then
        classRange[1] = 7
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 2
        classRange[2]["Fence"][4] = 999
        classRange[2]["Forest"][4] = 3
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 999
        classRange[2]["Peak"][4] = 999
        classRange[2]["Pillar"][4] = 3
        classRange[2]["River"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Knight B" units
    --[[
        03A8: Knight Lord
        0F24: Paladin (Male)
        0F78: Paladin (Female)
        1020: Valkyrie
    --]]
    if myClass == "3a8" or myClass == "f24" or myClass == "f78" or myClass == "1020"
    then 
        if myClass == "3a8"
        then
            classRange[1] = 7
        else 
            classRange[1] = 8
        end
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 2
        classRange[2]["Fence"][4] = 999
        classRange[2]["Forest"][4] = 3
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 6
        classRange[2]["Peak"][4] = 999
        classRange[2]["Pillar"][4] = 3
        classRange[2]["River"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Fighter" units 
    --[[
        0744: Fighter
        0798: Warrior
    --]]
    if myClass == "744" or myClass == "798"
    then
        if myClass == "798"
        then
            classRange[1] = 6
        end
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 3
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 3
        classRange[2]["Peak"][4] = 999
        classRange[2]["River"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Bandit" units. Note: Berserker is a Bandit AND and a Pirate. So I'm making a new "tier" for it
    --[[
        1410: Brigand
    --]]
    if myClass == "1410"
    then
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 3
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Pirate" units. Note: Like above, Berserker is not in this "tier"
    if myClass == "Pirate" or myClass == "Corsair"
    --[[
        1464: Pirate
        1B9C: Corsair
    --]]
    then
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Fence"][4] = 999
        classRange[2]["Mountain"][4] = 3
        classRange[2]["Peak"][4] = 999
        classRange[2]["River"][4] = 2
        classRange[2]["Snag"][4] = 999
    end
    --Actual Berserker
    --[[
        15BC: Berserker
    --]]
    if myClass == "14bc"
    then
        classRange[1] = 7
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Fence"][4] = 999
        classRange[2]["Mountain"][4] = 3
        classRange[2]["River"][4] = 2
        classRange[2]["Snag"][4] = 999
    end
    --"Mage" units
    --I am omitting Dark Druid and Magic Seal by design because they are not playable classes AND those enemies never move. 
    --Caution: I'm not actually sure if Kishuna (Magic Seal) moves or not any of his chapters. So, there might be a bug here!
    --[[
        0A8C: Monk
        0AE0: Cleric
        0B34: Bishop (Male)
        0B88: Bishop (Female)
        0BDC: Mage (Male)
        0C30: Mage (Female)
        0C84: Sage (Male)
        0CD8: Sage (Female)
        0D2C: Shaman (Male)
        0D80: Shaman (Female)
        0DD4: Druid (Male)
        0E28: Druid (Female)
        1704: Archsage
    --]]

    if myClass == "a8c" or myClass == "ae0" or myClass == "b34" or myClass == "b88" or myClass == "bdc" or myClass == "c30" or myClass == "c84" or myClass == "cd8" or myClass == "d2c" or myClass == "d80" or myClass == "dd4" or myClass == "e28" or myClass == "1704"
    then
        if myClass == "b34" or myClass == "b88" or myClass == "c84" or myClass == "cd8" or myClass == "dd4" or myClass == "e28" or myClass == "1704"
        then
            classRange[1] = 6
        end
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 1
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Peak"][4] = 999
        classRange[2]["River"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --"Flyer" units
    --[[
        11C4: Pegasus Knight
        1218: Falcon Knight
        126C: Wyvern Rider (Male)
        12C0: Wyvern Rider (Female)
        1314: Wyvern Lord (Male)
        1368: Wyvern Lord (Female)
    --]]
    if myClass == "11c4" or myClass == "1218" or myClass == "126c" or myClass == "12c0" or myClass == "1314" or myClass == "1368"
    then
        if myClass == "11c4" or myClass == "126c" or myClass == "12c0"
        then
            classRange[1] = 7
        else
            classRange[1] = 8
        end
        --Fliers suffer no movement penalties by terrain, however, they do not receive "non-healing" benefits (such as bonus def or avoid)
        --Thus, I need to edit pretty much all values in the terrain key as opposed to just the movement penalty.
        classRange[2]["Arena"] = {0, 0, 0, 1}
        classRange[2]["Desert"] = {0, 0, 0, 1}
        classRange[2]["Forest"] = {0, 0, 0, 1}
        classRange[2]["Fort"] = {0, 0, 0.20, 1}
        classRange[2]["Gate"] = {0, 0, 0.10, 1}
        classRange[2]["House"] = {0, 0, 0, 1}
        classRange[2]["Lake"] = {0, 0, 0, 1}
        classRange[2]["Mountain"] = {0, 0, 0, 1}
        classRange[2]["Peak"] = {0, 0, 0, 1}
        classRange[2]["Pillar"] = {0, 0, 0, 1}
        classRange[2]["River"] = {0, 0, 0, 1}
        classRange[2]["Ruins"] = {0, 0, 0, 1}
        classRange[2]["Ruins (Village)"] = {0, 0, 0, 1}
        classRange[2]["Sand"] = {0, 0, 0, 1}
        classRange[2]["Sea"] = {0, 0, 0, 1}
        classRange[2]["Shop"] = {0, 0, 0, 1}
        classRange[2]["Throne"] = {0, 0, 0.10, 1}
        classRange[2]["Village"] = {0, 0, 0, 1}
    end
    --Actual Nomad 
    --[[
        1074: Nomad (Male)
        10C8: Nomade (Female)
    --]]
    if myClass == "1074" or myClass == "10c8"
    then
        classRange[1] = 7
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 3
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 999
        classRange[2]["Peak"][4] = 999
        classRange[2]["Pillar"][4] = 3
        classRange[2]["River"][4] = 999
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    --Actual Nomad Trooper
    --[[
        111C: Nomad Trooper (Male)
        1170: Nomad Trooper (Female)
    -]]
    if myClass == "111c" or myClass == "1170"
    then
        classRange[1] = 8
        classRange[2]["Cliff"][4] = 999
        classRange[2]["Desert"][4] = 3
        classRange[2]["Fence"][4] = 999
        classRange[2]["Lake"][4] = 999
        classRange[2]["Mountain"][4] = 5
        classRange[2]["Peak"][4] = 999
        classRange[2]["Pillar"][4] = 3
        classRange[2]["Sea"][4] = 999
        classRange[2]["Snag"][4] = 999
    end
    return classRange
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

--Recall: 0x154b is Assassin
--thishex = GetClassType("154b")
--tprint(thishex)

M.GetClassType = GetClassType

return M