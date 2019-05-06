local M = {};
local reader = require("mapReader")
local globals = require("globals")

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
                if(v[3] < k[3]) then
                    return v;
                else
                    return k;
                end
            end
        end
    end
end

function discovered(list, new)
    for i,v in ipairs(list) do
        -- print(v[1] .. ", " .. v[2])
        -- print(new[1] .. ", " .. new[2])
        
        if v[1] == new[1] and v[2] == new[2] then
            -- print("returning true")
            -- print ("-------------------------")
            return i;
        end
    end
    -- print ("-------------------------")
            
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
    -- finds the adj space with the smallest cost
    smallestAdj = {0, 0, 999}
    for i,v in ipairs(list) do
        if ((v[2] == point[2] + 1 or v[2] == point[2] - 1) and
             v[1] == point[1])
            or
            ((v[1] == point[1] + 1 or v[1] == point[1] - 1) and
            v[2] == point[2] )then
                -- return v;
            -- if v[3] <= point[3]+1 then
            
            --     -- print(point[1] .. ", " .. point[2] .. " to " .. v[1] .. ", " .. v[2])
            --     return v
            if v[3] < smallestAdj[3] then
                smallestAdj = v
            
            end
        end
    end
    return smallestAdj
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

function BFS(startX, startY, endX, endY, map, terrainInfo)

    startSearch = {};
    startDiscovered = {};
    endSearch = {};
    endDiscovered = {};
    -- print(terrainInfo[1])
    -- print(#map .. ", " .. #map[1])
    if startY > #map 
    or startX  > #map[startY]
    or endY > #map
    or endX > #map[endY]
    or map[endY][endX][2] == 1
    or map[endY][endX][2] == 2
    or map[endY][endX][2] == 3
    then
        return {}
    end
    print(startY .. ", " .. startX .. " to " .. endY .. ", " .. endX)
    table.insert(startSearch, {startY, startX, 0});
    table.insert(endSearch, {endY, endX, terrainInfo[2][reader.shortToString[ map[endY][endX][1]]][4]});
    -- table.insert(endSearch, {endY, endX, 0})
    count = 1;
    while not overlap(startDiscovered, endDiscovered) 
    and (not globals.empty(startSearch)
    or not globals.empty(endSearch))
    do
        startTemp = #startSearch
        for i=1, startTemp do
            local tempStartPY = {}
            local tempStartPX = {}
            local tempStartNY = {}
            local tempStartNX = {}

            tempStartPY[1] = startSearch[1][1] + 1;
            tempStartPY[2] = startSearch[1][2];
            
            -- print(tempStartPY[1] .. ", " .. tempStartPY[2])

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
                -- print(tempStartPY[1] .. ", " .. tempStartPY[2])
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4] ~= 999
                and map[tempStartPY[1]][tempStartPY[2]][2] ~= 2
                and map[tempStartPY[1]][tempStartPY[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartPY)
                -- and not discovered(startSearch, tempStartPY) then
                -- print("not impassible")
                -- print(discovered(startDiscovered, tempStartPY))
                    if not discovered(startDiscovered, tempStartPY)
                    and not discovered(startSearch, tempStartPY) then
                        -- print("discovered in py")
                        -- print("----")
                        -- print(tempStartPY[1] .. ", " .. tempStartPY[2])
                        -- print(reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]])
                        -- print("----")
                        tempStartPY[3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4];
                        table.insert(startSearch, tempStartPY)
                    elseif discovered(startDiscovered, tempStartPY) then
                        -- print(discovered(startDiscovered, tempStartPY))
                        -- print("Discovered in startDiscovered")
                        if discovered(startDiscovered, tempStartPY) < #startDiscovered and 
                        startDiscovered[discovered(startDiscovered, tempStartPY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4]
                        then
                            print("updating: " .. tempStartPY[1] .. ", " .. tempStartPY[2])
                            startDiscovered[discovered(startDiscovered, tempStartPY)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4];
                        end
                    elseif discovered(startSearch, tempStartPY) and
                    discovered(startSearch, tempStartPY) < # startSearch and
                    startSearch[ discovered(startSearch, tempStartPY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4]
                    then
                        print("updating: " .. tempStartPY[1] .. ", " .. tempStartPY[2])
                        startSearch[discovered(startSearch, tempStartPY)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4];
                    
                    end
                end
            end

            -- discover in negative y direction from start
            -- print("looking at start ny")
            if tempStartNY[1] > 0
            and tempStartNY[2] <= #map[tempStartNY[1]] then
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4] ~= 999
                and map[tempStartNY[1]][tempStartNY[2]][2] ~= 2
                and map[tempStartNY[1]][tempStartNY[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartNY) 
                -- and not discovered(startSearch, tempStartNY) then
                    if not discovered(startDiscovered, tempStartNY) 
                    and not discovered(startSearch, tempStartNY) then
                        -- print("discovered in ny")
                        -- print("----")
                        -- print(tempStartNY[1] .. ", " .. tempStartNY[2])
                        -- print(reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]])
                        -- print("----")
                        tempStartNY[3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4];
                        table.insert(startSearch, tempStartNY)
                    elseif discovered(startDiscovered, tempStartNY) and
                    discovered(startDiscovered, tempStartNY) < #startDiscovered and 
                    startDiscovered[discovered(startDiscovered, tempStartNY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4]
                    then
                        print("updating: " .. tempStartNY[1] .. ", " .. tempStartNY[2])
                        startDiscovered[discovered(startDiscovered, tempStartNY)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4]
                    
                    elseif discovered(startSearch, tempStartNY) and
                    discovered(startSearch, tempStartNY) < #startSearch and
                    startSearch[ discovered(startSearch, tempStartNY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4] 
                    then
                        print("updating: " .. tempStartNY[1] .. ", " .. tempStartNY[2])
                        startSearch[ discovered(startSearch, tempStartNY)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4];
                        
                    end

                end
            end

            -- discover in positive x direction from start
            -- print("looking at start px")
            if tempStartPX[1] <= #map
            and tempStartPX[2] <= #map[tempStartPX[1]] then
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4] ~= 999
                and map[tempStartPX[1]][tempStartPX[2]][2] ~= 2
                and map[tempStartPX[1]][tempStartPX[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartPX)
                -- and not discovered(startSearch, tempStartPX) then
                    if not discovered(startDiscovered, tempStartPX)
                    and not discovered(startSearch, tempStartPX) then
                        -- print("discovered in px")
                        -- print("----")
                        -- print(tempStartPX[1] .. ", " .. tempStartPX[2])
                        -- print(reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]])
                        -- print("----")
                        tempStartPX[3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4];
                        table.insert(startSearch, tempStartPX)
                    elseif discovered(startDiscovered, tempStartPX) and
                    discovered(startDiscovered, tempStartPX) < #startDiscovered and 
                    startDiscovered[discovered(startDiscovered, tempStartPX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4]
                    then
                        print("updating: " .. tempStartPX[1] .. ", " .. tempStartPX[2])
                        startDiscovered[discovered(startDiscovered, tempStartPX)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4];
                        
                    elseif discovered(startSearch, tempStartPX) and
                    discovered(startSearch, tempStartPX) < #startSearch and
                    startSearch[discovered(startSearch, tempStartPX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4]
                    then
                        print("updating: " .. tempStartPX[1] .. ", " .. tempStartPX[2])
                        startSearch[discovered(startSearch, tempStartPX)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in negative x direction from start
            -- print("looking at start nx")
            if tempStartNX[1] <= #map
            and tempStartNX[2] > 0 then
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4] ~= 999
                and map[tempStartNX[1]][tempStartNX[2]][2] ~= 2
                and map[tempStartNX[1]][tempStartNX[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartNX) 
                -- and not discovered(startSearch, tempStartNX) then
                    if not discovered(startDiscovered, tempStartNX) 
                    and not discovered(startSearch, tempStartNX) then
                        -- print("discovered in nx")
                        -- print("----")
                        -- print(tempStartNX[1] .. ", " .. tempStartNX[2])
                        -- print(reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]])
                        -- print("cost: " .. startSearch[1][3] +terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4])
                        -- print("----")
                        tempStartNX[3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4];
                        
                        table.insert(startSearch, tempStartNX)
                    elseif discovered(startDiscovered, tempStartNX) and
                    discovered(startDiscovered, tempStartNX) < #startDiscovered and 
                    startDiscovered[discovered(startDiscovered, tempStartNX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4]
                    then
                        print("updating: ".. tempStartNX[1] .. ", " .. tempStartNX[2])
                        startDiscovered[discovered(startDiscovered, tempStartNX)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4]

                    elseif discovered(startSearch, tempStartNX) and
                    discovered(startSearch, tempStartNX) < #startSearch and
                    startSearch[discovered(startSearch, tempStartNX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4]
                    then
                        print("updating: ".. tempStartNX[1] .. ", " .. tempStartNX[2])
                        startSearch[discovered(startSearch, tempStartNX)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4];
                        
                    end
                end
            end
            
            table.insert(startDiscovered, startSearch[1])
            table.remove(startSearch, 1)
        end
        -- print("-----------------------")
        -- tprint(startSearch)
        -- print("-----------------------")

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
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4] ~= 999
                and map[tempEndPY[1]][tempEndPY[2]][2] ~= 2
                and map[tempEndPY[1]][tempEndPY[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndPY) 
                -- and not discovered(endSearch, tempEndPY) 
                    if not discovered(endDiscovered, tempEndPY)
                    and not discovered(endSearch, tempEndPY) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]])
                        tempEndPY[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4];
                        table.insert(endSearch, tempEndPY)
                    elseif discovered(endDiscovered, tempEndPY) and
                    discovered(endDiscovered, tempEndPY) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndPY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndPY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndPY) and
                    discovered(endSearch, tempEndPY) < #endSearch and
                    endSearch[discovered(endSearch, tempEndPY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndPY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in negative y direction from end
            -- print("lookint at end ny")
            if tempEndNY[1] > 0
            and tempEndNY[2] <= #map[tempEndNY[1]] then
                -- within bounds
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4] ~= 999
                and map[tempEndNY[1]][tempEndNY[2]][2] ~= 2
                and map[tempEndNY[1]][tempEndNY[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndNY) 
                -- and not discovered(endSearch, tempEndNY) then 
                    if not discovered(endDiscovered, tempEndNY)
                    and not discovered(endSearch, tempEndNY) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]])
                        tempEndNY[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4];
                        table.insert(endSearch, tempEndNY)
                    elseif discovered(endDiscovered, tempEndNY) and
                    discovered(endDiscovered, tempEndNY) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndNY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndNY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndNY) and
                    discovered(endSearch, tempEndNY) < #endSearch and
                    endSearch[discovered(endSearch, tempEndNY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndNY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in positive x direction from end
            -- print("lookint at end px")
            if tempEndPX[1] <= #map
            and tempEndPX[2] <= #map[tempEndPX[1]] then
                -- within bounds
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4] ~= 999
                and map[tempEndPX[1]][tempEndPX[2]][2] ~= 2
                and map[tempEndPX[1]][tempEndPX[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndPX) 
                -- and not discovered(endSearch, tempEndPX) then 
                    if not discovered(endDiscovered, tempEndPX)
                    and not discovered(endSearch, tempEndPX) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]])
                        tempEndPX[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4];
                        table.insert(endSearch, tempEndPX)
                    elseif discovered(endDiscovered, tempEndPX) and
                    discovered(endDiscovered, tempEndPX) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndPX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndPX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndPX) and
                    discovered(endSearch, tempEndPX) < #endSearch and
                    endSearch[discovered(endSearch, tempEndPX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndPX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in negative x direction from end
            -- print("lookint at end nx")
            if tempEndNX[1] <= #map
            and tempEndNX[2] > 0 then
                -- within bounds
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4] ~= 999
                and map[tempEndNX[1]][tempEndNX[2]][2] ~= 2
                and map[tempEndNX[1]][tempEndNX[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndNX) 
                -- and not discovered(endSearch, tempEndNX) then 
                    if not discovered(endDiscovered, tempEndNX)
                    and not discovered(endSearch, tempEndNX) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]])
                        tempEndNX[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4];
                        table.insert(endSearch, tempEndNX)
                    elseif discovered(endDiscovered, tempEndNX) and
                    discovered(endDiscovered, tempEndNX) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndNX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndNX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndNX) and
                    discovered(endSearch, tempEndNX) < #endSearch and
                    endSearch[discovered(endSearch, tempEndNX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndNX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4];
                        
                    end
                end
            end
            table.insert(endDiscovered, endSearch[1])
            table.remove(endSearch, 1)
        end
        -- print("-----------------------")
        -- tprint(endSearch)
        -- print("-----------------------")
        
        count = count + 1;
    end 

    -- tprint(startDiscovered);
    -- print("--------------------------------")
    -- tprint(endDiscovered);
    if globals.empty(startSearch) 
    or globals.empty(endSearch)
    then
        return {}
    end

    -- print("found overlap")
    path = {}
    centerSpot = getOverlap(startDiscovered, endDiscovered);
    table.insert(path, 1, centerSpot)
    print(centerSpot[1] .. ", " .. centerSpot[2])
    while(path[1][1] ~= startY or path[1][2] ~= startX) do 
        -- print("in first while")
        next = findNext(startDiscovered, path[1])
        if next[3] == 999 then
            return {}
        end
        -- tprint(next)
        table.insert(path, 1, next)
        startDiscovered = removeDistance(startDiscovered, path[1][3])
        -- print("--------------------------------------")
        -- tprint(startDiscovered);
    end
    -- print("test")
    -- tprint(path)
    -- tprint(endDiscovered)
    while(path[#path][1] ~= endY or path[#path][2] ~= endX) do 
        -- print("in second while")
        next = findNext(endDiscovered, path[#path])
        if(next[3] == 999) then
            return {};
        end
        -- tprint(next)
        -- print(next[1] .. ", " .. next[2])
        table.insert(path, next)
        endDiscovered = removeDistance(endDiscovered, path[#path][3])
        -- print("--------------------------------------")
        -- tprint(endDiscovered);
    end
    -- print("printing path")
    -- tprint(path)
    -- print("end BFS")
    return path


end

function goalPath(startX, startY, endX, endY, map, terrainInfo)

    startSearch = {};
    startDiscovered = {};
    endSearch = {};
    endDiscovered = {};
    -- print(terrainInfo[1])
    -- print(#map .. ", " .. #map[1])
    if startY > #map 
    or startX  > #map[startY]
    or endY > #map
    or endX > #map[endY]
    -- or map[endY][endX][2] == 1
    -- or map[endY][endX][2] == 2
    -- or map[endY][endX][2] == 3
    then
        return {}
    end
    print(startY .. ", " .. startX .. " to " .. endY .. ", " .. endX)
    table.insert(startSearch, {startY, startX, 0});
    table.insert(endSearch, {endY, endX, terrainInfo[2][reader.shortToString[ map[endY][endX][1]]][4]});
    -- table.insert(endSearch, {endY, endX, 0})
    count = 1;
    while not overlap(startDiscovered, endDiscovered) 
    and (not globals.empty(startSearch)
    or not globals.empty(endSearch))
    do
        startTemp = #startSearch
        for i=1, startTemp do
            local tempStartPY = {}
            local tempStartPX = {}
            local tempStartNY = {}
            local tempStartNX = {}

            tempStartPY[1] = startSearch[1][1] + 1;
            tempStartPY[2] = startSearch[1][2];
            
            -- print(tempStartPY[1] .. ", " .. tempStartPY[2])

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
                -- print(tempStartPY[1] .. ", " .. tempStartPY[2])
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4] ~= 999
                -- and map[tempStartPY[1]][tempStartPY[2]][2] ~= 2
                -- and map[tempStartPY[1]][tempStartPY[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartPY)
                -- and not discovered(startSearch, tempStartPY) then
                -- print("not impassible")
                -- print(discovered(startDiscovered, tempStartPY))
                    if not discovered(startDiscovered, tempStartPY)
                    and not discovered(startSearch, tempStartPY) then
                        -- print("discovered in py")
                        -- print("----")
                        -- print(tempStartPY[1] .. ", " .. tempStartPY[2])
                        -- print(reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]])
                        -- print("----")
                        tempStartPY[3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4];
                        table.insert(startSearch, tempStartPY)
                    elseif discovered(startDiscovered, tempStartPY) then
                        -- print(discovered(startDiscovered, tempStartPY))
                        -- print("Discovered in startDiscovered")
                        if discovered(startDiscovered, tempStartPY) < #startDiscovered and 
                        startDiscovered[discovered(startDiscovered, tempStartPY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4]
                        then
                            print("updating: " .. tempStartPY[1] .. ", " .. tempStartPY[2])
                            startDiscovered[discovered(startDiscovered, tempStartPY)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4];
                        end
                    elseif discovered(startSearch, tempStartPY) and
                    discovered(startSearch, tempStartPY) < # startSearch and
                    startSearch[ discovered(startSearch, tempStartPY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4]
                    then
                        print("updating: " .. tempStartPY[1] .. ", " .. tempStartPY[2])
                        startSearch[discovered(startSearch, tempStartPY)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPY[1]][tempStartPY[2]][1]]][4];
                    
                    end
                end
            end

            -- discover in negative y direction from start
            -- print("looking at start ny")
            if tempStartNY[1] > 0
            and tempStartNY[2] <= #map[tempStartNY[1]] then
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4] ~= 999
                -- and map[tempStartNY[1]][tempStartNY[2]][2] ~= 2
                -- and map[tempStartNY[1]][tempStartNY[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartNY) 
                -- and not discovered(startSearch, tempStartNY) then
                    if not discovered(startDiscovered, tempStartNY) 
                    and not discovered(startSearch, tempStartNY) then
                        -- print("discovered in ny")
                        -- print("----")
                        -- print(tempStartNY[1] .. ", " .. tempStartNY[2])
                        -- print(reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]])
                        -- print("----")
                        tempStartNY[3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4];
                        table.insert(startSearch, tempStartNY)
                    elseif discovered(startDiscovered, tempStartNY) and
                    discovered(startDiscovered, tempStartNY) < #startDiscovered and 
                    startDiscovered[discovered(startDiscovered, tempStartNY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4]
                    then
                        print("updating: " .. tempStartNY[1] .. ", " .. tempStartNY[2])
                        startDiscovered[discovered(startDiscovered, tempStartNY)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4]
                    
                    elseif discovered(startSearch, tempStartNY) and
                    discovered(startSearch, tempStartNY) < #startSearch and
                    startSearch[ discovered(startSearch, tempStartNY)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4] 
                    then
                        print("updating: " .. tempStartNY[1] .. ", " .. tempStartNY[2])
                        startSearch[ discovered(startSearch, tempStartNY)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNY[1]][tempStartNY[2]][1]]][4];
                        
                    end

                end
            end

            -- discover in positive x direction from start
            -- print("looking at start px")
            if tempStartPX[1] <= #map
            and tempStartPX[2] <= #map[tempStartPX[1]] then
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4] ~= 999
                -- and map[tempStartPX[1]][tempStartPX[2]][2] ~= 2
                -- and map[tempStartPX[1]][tempStartPX[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartPX)
                -- and not discovered(startSearch, tempStartPX) then
                    if not discovered(startDiscovered, tempStartPX)
                    and not discovered(startSearch, tempStartPX) then
                        -- print("discovered in px")
                        -- print("----")
                        -- print(tempStartPX[1] .. ", " .. tempStartPX[2])
                        -- print(reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]])
                        -- print("----")
                        tempStartPX[3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4];
                        table.insert(startSearch, tempStartPX)
                    elseif discovered(startDiscovered, tempStartPX) and
                    discovered(startDiscovered, tempStartPX) < #startDiscovered and 
                    startDiscovered[discovered(startDiscovered, tempStartPX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4]
                    then
                        print("updating: " .. tempStartPX[1] .. ", " .. tempStartPX[2])
                        startDiscovered[discovered(startDiscovered, tempStartPX)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4];
                        
                    elseif discovered(startSearch, tempStartPX) and
                    discovered(startSearch, tempStartPX) < #startSearch and
                    startSearch[discovered(startSearch, tempStartPX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4]
                    then
                        print("updating: " .. tempStartPX[1] .. ", " .. tempStartPX[2])
                        startSearch[discovered(startSearch, tempStartPX)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartPX[1]][tempStartPX[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in negative x direction from start
            -- print("looking at start nx")
            if tempStartNX[1] <= #map
            and tempStartNX[2] > 0 then
                -- within bounds
                if -- map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempStartPY[1]][tempStartPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4] ~= 999
                -- and map[tempStartNX[1]][tempStartNX[2]][2] ~= 2
                -- and map[tempStartNX[1]][tempStartNX[2]][2] ~= 3
                then
                -- and not discovered(startDiscovered, tempStartNX) 
                -- and not discovered(startSearch, tempStartNX) then
                    if not discovered(startDiscovered, tempStartNX) 
                    and not discovered(startSearch, tempStartNX) then
                        -- print("discovered in nx")
                        -- print("----")
                        -- print(tempStartNX[1] .. ", " .. tempStartNX[2])
                        -- print(reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]])
                        -- print("cost: " .. startSearch[1][3] +terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4])
                        -- print("----")
                        tempStartNX[3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4];
                        
                        table.insert(startSearch, tempStartNX)
                    elseif discovered(startDiscovered, tempStartNX) and
                    discovered(startDiscovered, tempStartNX) < #startDiscovered and 
                    startDiscovered[discovered(startDiscovered, tempStartNX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4]
                    then
                        print("updating: ".. tempStartNX[1] .. ", " .. tempStartNX[2])
                        startDiscovered[discovered(startDiscovered, tempStartNX)][3] = startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4]

                    elseif discovered(startSearch, tempStartNX) and
                    discovered(startSearch, tempStartNX) < #startSearch and
                    startSearch[discovered(startSearch, tempStartNX)][3] > startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4]
                    then
                        print("updating: ".. tempStartNX[1] .. ", " .. tempStartNX[2])
                        startSearch[discovered(startSearch, tempStartNX)][3] =  startSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempStartNX[1]][tempStartNX[2]][1]]][4];
                        
                    end
                end
            end
            
            table.insert(startDiscovered, startSearch[1])
            table.remove(startSearch, 1)
        end
        -- print("-----------------------")
        -- tprint(startSearch)
        -- print("-----------------------")

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
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4] ~= 999
                -- and map[tempEndPY[1]][tempEndPY[2]][2] ~= 2
                -- and map[tempEndPY[1]][tempEndPY[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndPY) 
                -- and not discovered(endSearch, tempEndPY) 
                    if not discovered(endDiscovered, tempEndPY)
                    and not discovered(endSearch, tempEndPY) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]])
                        tempEndPY[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4];
                        table.insert(endSearch, tempEndPY)
                    elseif discovered(endDiscovered, tempEndPY) and
                    discovered(endDiscovered, tempEndPY) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndPY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndPY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndPY) and
                    discovered(endSearch, tempEndPY) < #endSearch and
                    endSearch[discovered(endSearch, tempEndPY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndPY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPY[1]][tempEndPY[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in negative y direction from end
            -- print("lookint at end ny")
            if tempEndNY[1] > 0
            and tempEndNY[2] <= #map[tempEndNY[1]] then
                -- within bounds
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4] ~= 999
                -- and map[tempEndNY[1]][tempEndNY[2]][2] ~= 2
                -- and map[tempEndNY[1]][tempEndNY[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndNY) 
                -- and not discovered(endSearch, tempEndNY) then 
                    if not discovered(endDiscovered, tempEndNY)
                    and not discovered(endSearch, tempEndNY) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]])
                        tempEndNY[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4];
                        table.insert(endSearch, tempEndNY)
                    elseif discovered(endDiscovered, tempEndNY) and
                    discovered(endDiscovered, tempEndNY) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndNY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndNY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndNY) and
                    discovered(endSearch, tempEndNY) < #endSearch and
                    endSearch[discovered(endSearch, tempEndNY)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndNY)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNY[1]][tempEndNY[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in positive x direction from end
            -- print("lookint at end px")
            if tempEndPX[1] <= #map
            and tempEndPX[2] <= #map[tempEndPX[1]] then
                -- within bounds
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4] ~= 999
                -- and map[tempEndPX[1]][tempEndPX[2]][2] ~= 2
                -- and map[tempEndPX[1]][tempEndPX[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndPX) 
                -- and not discovered(endSearch, tempEndPX) then 
                    if not discovered(endDiscovered, tempEndPX)
                    and not discovered(endSearch, tempEndPX) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]])
                        tempEndPX[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4];
                        table.insert(endSearch, tempEndPX)
                    elseif discovered(endDiscovered, tempEndPX) and
                    discovered(endDiscovered, tempEndPX) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndPX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndPX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndPX) and
                    discovered(endSearch, tempEndPX) < #endSearch and
                    endSearch[discovered(endSearch, tempEndPX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndPX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndPX[1]][tempEndPX[2]][1]]][4];
                        
                    end
                end
            end

            -- discover in negative x direction from end
            -- print("lookint at end nx")
            if tempEndNX[1] <= #map
            and tempEndNX[2] > 0 then
                -- within bounds
                if -- map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Peak"] 
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["Cliff"]
                -- and map[tempEndPY[1]][tempEndPY[2]][1] ~= reader.stringToShort["---"]
                terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4] ~= 999
                -- and map[tempEndNX[1]][tempEndNX[2]][2] ~= 2
                -- and map[tempEndNX[1]][tempEndNX[2]][2] ~= 3
                then
                -- and not discovered(endDiscovered, tempEndNX) 
                -- and not discovered(endSearch, tempEndNX) then 
                    if not discovered(endDiscovered, tempEndNX)
                    and not discovered(endSearch, tempEndNX) then
                        -- print("discovered in px")
                        -- print(reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]])
                        tempEndNX[3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4];
                        table.insert(endSearch, tempEndNX)
                    elseif discovered(endDiscovered, tempEndNX) and
                    discovered(endDiscovered, tempEndNX) < #endDiscovered and 
                    endDiscovered[discovered(endDiscovered, tempEndNX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4]
                    then
                        endDiscovered[discovered(endDiscovered, tempEndNX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4];
                        
                    elseif discovered(endSearch, tempEndNX) and
                    discovered(endSearch, tempEndNX) < #endSearch and
                    endSearch[discovered(endSearch, tempEndNX)][3] > endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4]
                    then
                        endSearch[discovered(endSearch, tempEndNX)][3] =  endSearch[1][3] + terrainInfo[2][reader.shortToString[ map[tempEndNX[1]][tempEndNX[2]][1]]][4];
                        
                    end
                end
            end
            table.insert(endDiscovered, endSearch[1])
            table.remove(endSearch, 1)
        end
        -- print("-----------------------")
        -- tprint(endSearch)
        -- print("-----------------------")
        
        count = count + 1;
    end 

    -- tprint(startDiscovered);
    -- print("--------------------------------")
    -- tprint(endDiscovered);
    if globals.empty(startSearch) 
    or globals.empty(endSearch)
    then
        return {}
    end

    -- print("found overlap")
    path = {}
    centerSpot = getOverlap(startDiscovered, endDiscovered);
    table.insert(path, 1, centerSpot)
    print(centerSpot[1] .. ", " .. centerSpot[2])
    while(path[1][1] ~= startY or path[1][2] ~= startX) do 
        -- print("in first while")
        next = findNext(startDiscovered, path[1])
        if next[3] == 999 then
            return {}
        end
        -- tprint(next)
        table.insert(path, 1, next)
        startDiscovered = removeDistance(startDiscovered, path[1][3])
        -- print("--------------------------------------")
        -- tprint(startDiscovered);
    end
    -- print("test")
    -- tprint(path)
    -- tprint(endDiscovered)
    while(path[#path][1] ~= endY or path[#path][2] ~= endX) do 
        -- print("in second while")
        next = findNext(endDiscovered, path[#path])
        if(next[3] == 999) then
            return {};
        end
        -- tprint(next)
        -- print(next[1] .. ", " .. next[2])
        table.insert(path, next)
        endDiscovered = removeDistance(endDiscovered, path[#path][3])
        -- print("--------------------------------------")
        -- tprint(endDiscovered);
    end
    -- print("printing path")
    -- tprint(path)
    -- print("end BFS")
    return path


end

function getLengthOfPath(path, map, terrainInfo)
    count = 1;
    distance = 0;
    if(globals.empty(path)) then
        -- print("non existant path")
        return 999
    end
    -- tprint(path)
    -- while(path[count + 1][3] > path[count][3]) do
        
        -- print(reader.shortToString [ map [path[count+1][1]][ path[count+1][2] ][1] ])
    --     distance = distance + terrainInfo[2] [reader.shortToString [ map [path[count+1][1]][ path[count+1][2] ][1] ] ] [4];
    --     count = count + 1
    --     print(count)
    -- end

    for count = count, #path - 1 do 
        -- print(reader.shortToString [ map [path[count+1][1]][ path[count+1][2] ][1] ])
        distance = distance + terrainInfo[2][reader.shortToString [ map [path[count+1][1]][ path[count+1][2] ][1] ]] [4];
    end

    -- distance = distance + path[#path][3]

    return distance
end

M.BFS = BFS;
M.getLengthOfPath = getLengthOfPath
M.goalPath = goalPath

return M;