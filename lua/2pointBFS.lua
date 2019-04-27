local M = {};
local reader = require("mapReader")

function overlap (startSearch, endSearch)
    for i,v in ipairs(startSearch) do
        for j,k in ipairs(endSearch) do
            if v[1] == k[1] and v[2] == k[2] then
                return true;
            end
        end
    end
    return false;
end

function discovered(list, new)
    for i,v in ipairs(list) do
        if v[1] == new[1] and v[2] == new[2] then
            return true;
        end
    end
    return false;

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

function BFS(startX, startY, endX, endY, map)

    startSearch = {};
    startDiscoverd = {};
    endSearch = {};
    endDiscovered = {};
    -- print(#map .. ", " .. #map[1])
    table.insert(startSearch, {startY, startX, 0});
    table.insert(endSearch, {endY, endX, 0});
    count = 0;
    --while not overlap(startDiscoverd, endDiscovered) do
        for i=1, #startSearch do
            local tempStartPY = {}
            local tempStartPX = {}
            local tempStartNY = {}
            local tempStartNX = {}

            tempStartPY[1] = startSearch[1][1] + 1;
            tempStartPY[2] = startSearch[1][2];

            tempStartNY[1] = startSearch[1][1] - 1;
            tempStartNY[2] = startSearch[1][2];
            
            tempStartPX[1] = startSearch[1][1];
            tempStartPX[2] = startSearch[1][2] + 1
            
            tempStartNX[1] = startSearch[1][1];
            tempStartNX[2] = startSearch[1][2] - 1;
            -- print(reader.map[1][1][1])
            
            -- discover in positive y direction
            if tempStartPY[1] <= #map 
            and tempStartPY[2]  <= #map[tempStartPY[1]] then
                -- within bounds
                if map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.key["Peak"] 
                and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.key["Cliff"]
                and not discovered(startDiscoverd, tempStartPY) then
                    print("discovered in py")
                    table.insert(startSearch, tempStartPY)
                end
            end

            -- discover in negative y directio n
            if tempStartNY[1] > 0
            and tempStartNY[2] <= #map[tempStartNY[1]] then
                -- within bounds
                if map[tempStartNY[1]][tempStartNY[2]][1] ~= reader.key["Peak"]
                and map[tempStartNY[1]][tempStartNY[2]] ~= reader.key["Cliff"]
                and not discover(startDiscoverd, tempStartNY) then

                    
                end
            end

            
        end
        count = count + 1;
    --end 

end

M.BFS = BFS;

return M;