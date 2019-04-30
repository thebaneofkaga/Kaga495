local M = {};
local reader = require("mapReader")

function overlap (startSearch, endSearch)
    for i,v in ipairs(startSearch) do
        -- print(v[1] .. ", " .. v[2]..", " .. v[3])
        for j,k in ipairs(endSearch) do
            -- print("\t"..k[1] ..", ".. k[2]..", ".. k[3])
            if v[1] == k[1] and v[2] == k[2] then
                return true;
            end
        end
    end
    return false;
end

function getOverlap(startDiscover, endDiscover)
    for i,v in ipairs(startDiscover) do
        -- print(v[1] .. ", " .. v[2]..", " .. v[3])
        for j,k in ipairs(endDiscover) do
            -- print("\t"..k[1] ..", ".. k[2]..", ".. k[3])
            if v[1] == k[1] and v[2] == k[2] then
                return k;
            end
        end
    end
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

function findNext(list, point)
    for i,v in ipairs(list) do
        if v[3] == point[3] - 1 then
            if ((v[2] == point[2] + 1 or v[2] == point[2] - 1) and
             v[1] == point[1])
            or
            ((v[1] == point[1] + 1 or v[1] == point[1] - 1) and
            v[2] == point[2] )then
                -- print(point[1] .. ", " .. point[2] .. " to " .. v[1] .. ", " .. v[2])
                return v
            end
        end
    end
end

function removeDistance(list, dist)
    toReturn = {}
    for i,v in ipairs(list) do
        if v[3] < dist then
            -- print(i ..":" .. v[1] .. " , " .. v[2] .. ", " .. v[3])
            table.insert(toReturn, v)
        end
    end
    -- for i = 1, #list do 
    --     if list[i][3] >= dist then
    --         print(i ..":" .. list[i][1] .. " , " .. list[i][2] .. ", " .. list[i][3])
    --         table.insert(toRemove, i)
    --     end
    -- end
    -- for i,v in ipairs(toRemove) do
    --     print(v)
    --     print("removing " .. v .. ": " .. list[v][1] .. ", " .. list[v][2] .. ", " .. list[v][3])
    --     table.remove(list, v)
    -- end
    -- tprint(toReturn)
    return toReturn;
end

function BFS(startX, startY, endX, endY, map)

    startSearch = {};
    startDiscoverd = {};
    endSearch = {};
    endDiscoverd = {};
    -- print(#map .. ", " .. #map[1])
    table.insert(startSearch, {startY, startX, 0});
    table.insert(endSearch, {endY, endX, 0});
    count = 1;
    while not overlap(startDiscoverd, endDiscoverd) do
        startTemp = #startSearch
        for i=1, startTemp do
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
            
            -- discover in positive y direction from start
            -- print("looking at start py")
            if tempStartPY[1] <= #map 
            and tempStartPY[2]  <= #map[tempStartPY[1]] then
                -- print("py within bounds")
                -- within bounds
                if map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.key["Peak"] 
                and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.key["Cliff"]
                and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.key["---"]
                and not discovered(startDiscoverd, tempStartPY)
                and not discovered(startSearch, tempStartPY) then
                    -- print("discovered in py")
                    tempStartPY[3] = count;
                    table.insert(startSearch, tempStartPY)
                end
            end

            -- discover in negative y direction from start
            -- print("looking at start ny")
            if tempStartNY[1] > 0
            and tempStartNY[2] <= #map[tempStartNY[1]] then
                -- within bounds
                if map[tempStartNY[1]][tempStartNY[2]][1] ~= reader.key["Peak"]
                and map[tempStartNY[1]][tempStartNY[2]][1] ~= reader.key["Cliff"]
                and map[tempStartNY[1]][tempStartNY[2]][1] ~= reader.key["---"]
                and not discovered(startDiscoverd, tempStartNY) 
                and not discovered(startSearch, tempStartNY) then
                    -- print("discovered in ny")
                    tempStartNY[3] = count;
                    table.insert(startSearch, tempStartNY)
                end
            end

            -- discover in positive x direction from start
            -- print("looking at start px")
            if tempStartPX[1] <= #map
            and tempStartPX[2] <= #map[tempStartPX[1]] then
                -- within bounds
                if map[tempStartPX[1]][tempStartPX[2]][1] ~= reader.key["Peak"]
                and map[tempStartPX[1]][tempStartPX[2]][1] ~= reader.key["Cliff"] 
                and map[tempStartPX[1]][tempStartPX[2]][1] ~= reader.key["---"] 
                and not discovered(startDiscoverd, tempStartPX)
                and not discovered(startSearch, tempStartPX) then
                    -- print("discovered in px")
                    tempStartPX[3] = count;
                    table.insert(startSearch, tempStartPX)
                end
            end

            -- discover in negative x direction from start
            -- print("looking at start nx")
            if tempStartNX[1] <= #map
            and tempStartNX[2] > 0 then
                -- within bounds
                if map[tempStartNX[1]][tempStartNX[2]][1] ~= reader.key["Peak"]
                and map[tempStartNX[1]][tempStartNX[2]][1] ~= reader.key["Cliff"]
                and map[tempStartNX[1]][tempStartNX[2]][1] ~= reader.key["---"]
                and not discovered(startDiscoverd, tempStartNX) 
                and not discovered(startSearch, tempStartNX) then
                    -- print("discovered in nx")
                    tempStartNX[3] = count;
                    table.insert(startSearch, tempStartNX)
                end
            end
            
            table.insert(startDiscoverd, startSearch[1])
            table.remove(startSearch, 1)
        end
            ----------------------------------------------
        endTemp = #endSearch
        for i=1, endTemp do
            local tempEndPY = {}
            local tempEndPX = {}
            local tempEndNY = {}
            local tempEndNX = {}
            
            tempEndPY[1] = endSearch[1][1] + 1
            tempEndPY[2] = endSearch[1][2]

            tempEndNY[1] = endSearch[1][1] - 1
            tempEndNY[2] = endSearch[1][2]

            tempEndPX[1] = endSearch[1][1]
            tempEndPX[2] = endSearch[1][2] + 1

            tempEndNX[1] = endSearch[1][1]
            tempEndNX[2] = endSearch[1][2] - 1

            -- discover in positive y direction from end
            -- print("lookint at end py")
            if tempEndPY[1] <= #map 
            and tempEndPY[2]  <= #map[tempEndPY[1]] then
                -- within bounds
                if map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.key["Peak"] 
                and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.key["Cliff"]
                and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.key["---"]
                and not discovered(endDiscoverd, tempEndPY) 
                and not discovered(endSearch, tempEndPY) then 
                    -- print("discovered in py")
                    tempEndPY[3] = count;
                    table.insert(endSearch, tempEndPY)
                end
            end

            -- discover in negative y direction from end
            -- print("lookint at end ny")
            if tempEndNY[1] > 0
            and tempEndNY[2] <= #map[tempEndNY[1]] then
                -- within bounds
                if map[tempEndNY[1]][tempEndNY[2]][1] ~= reader.key["Peak"]
                and map[tempEndNY[1]][tempEndNY[2]][1] ~= reader.key["Cliff"]
                and map[tempEndNY[1]][tempEndNY[2]][1] ~= reader.key["---"]
                and not discovered(endDiscoverd, tempEndNY) 
                and not discovered(endSearch, tempEndNY) then
                    -- print("discovered in ny")
                    tempEndNY[3] = count;
                    table.insert(endSearch, tempEndNY)
                end
            end

            -- discover in positive x direction from end
            -- print("lookint at end px")
            if tempEndPX[1] <= #map
            and tempEndPX[2] <= #map[tempEndPX[1]] then
                -- within bounds
                if map[tempEndPX[1]][tempEndPX[2]][1] ~= reader.key["Peak"]
                and map[tempEndPX[1]][tempEndPX[2]][1] ~= reader.key["Cliff"] 
                and map[tempEndPX[1]][tempEndPX[2]][1] ~= reader.key["---"] 
                and not discovered(endDiscoverd, tempEndPX) 
                and not discovered(endSearch, tempEndPX) then
                    -- print("discovered in px")
                    tempEndPX[3] = count;
                    table.insert(endSearch, tempEndPX)
                end
            end

            -- discover in negative x direction from end
            -- print("lookint at end nx")
            if tempEndNX[1] <= #map
            and tempEndNX[2] > 0 then
                -- within bounds
                if map[tempEndNX[1]][tempEndNX[2]][1] ~= reader.key["Peak"]
                and map[tempEndNX[1]][tempEndNX[2]][1] ~= reader.key["Cliff"]
                and map[tempEndNX[1]][tempEndNX[2]][1] ~= reader.key["---"]
                and not discovered(endDiscoverd, tempEndNX) 
                and not discovered(endSearch, tempEndNX) then
                    -- print("discovered in nx")
                    tempEndNX[3] = count;
                    table.insert(endSearch, tempEndNX)
                end
            end
            table.insert(endDiscoverd, endSearch[1])
            table.remove(endSearch, 1)
        end
        
        count = count + 1;
    end 

    -- tprint(startDiscoverd);
    -- print("--------------------------------")
    -- tprint(endDiscoverd);

    path = {}
    centerSpot = getOverlap(startDiscoverd, endDiscoverd);
    table.insert(path, 1, centerSpot)
    -- print(centerSpot[1] .. ", " .. centerSpot[2])
    while(path[1][3] ~= 0) do 
        next = findNext(startDiscoverd, path[1])
        -- tprint(next)
        table.insert(path, 1, next)
        startDiscoverd = removeDistance(startDiscoverd, path[1][3])
        -- print("--------------------------------------")
        -- tprint(startDiscoverd);
    end
    while(path[#path][3] ~= 0) do 
        next = findNext(endDiscoverd, path[#path])
        -- tprint(next)
        table.insert(path, next)
        endDiscoverd = removeDistance(endDiscoverd, path[#path][3])
        -- print("--------------------------------------")
        -- tprint(endDiscoverd);
    end
    -- print("printing path")
    -- tprint(path)
    
    return path


end

M.BFS = BFS;

return M;