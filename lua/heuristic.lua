local M = {}

local TheCharData = require("chardata")

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

function getNextCharMove(character)
    
end

function GroupHeuristic(tableOfCharacters)
    move = "";

    TheCharData.PrintTable(tableOfCharacters)

    for i,v in ipairs(tableOfCharacters) do
        move = getNextCharMove(v)
    end


end
---[[
GroupHeuristic(TheCharData.PlayerUnits);


--]]


M.GroupHeuristic = GroupHeuristic;

return M;