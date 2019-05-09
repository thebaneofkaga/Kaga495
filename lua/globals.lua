local M = {}

-- found in solutions to 
-- https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
-- by user FichteFoll
function empty(self)
    if self == nil then
        return true
    end
    for i,v in ipairs(self) do
        return false
    end
    return true
end

function signOf(int)
    if int > 0 then
        return 1
    elseif int < 0 then
        return -1
    else
        return 0
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

function elementNotInTable(element, table)
    for i,v in ipairs(table) do
        print(element .. " == " .. v)
        if v == element then
            return false
        end
    end
    return true
end

M.tprint = tprint
M.empty = empty
M.signOf = signOf
M.elementNotInTable = elementNotInTable

return M