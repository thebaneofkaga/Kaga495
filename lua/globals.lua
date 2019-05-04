local M = {}

-- found in solutions to 
-- https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
-- by user FichteFoll
function empty(self)
    for i,v in ipairs(self) do
        return false
    end
    return true
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

M.tprint = tprint
M.empty = empty

return M