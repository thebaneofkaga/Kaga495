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

function printGrid(grid, startY, startX, endY, endX)
    for j=1, 10 do
        for i=1, 11 do
            if j == startY and i == startX then
                io.write("S ")
            elseif j == endY and i == endX then
                io.write("E ")
            else
                io.write(grid[j][i] .. " ");
            end
        end
        print("");
    end
    print("\n")
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

print("greetings master");

grid = {};
for i=1 , 10 do
    grid[i] = {};
end

grid[1] = {"x", "x", "x", "x", "x", "x", "x", "x", "x", "x", " "};
grid[2] = {" ", " ", "x", "x", " ", " ", "x", " ", " ", " ", " "};
grid[3] = {" ", " ", "x", "x", " ", " ", "x", " ", " ", " ", " "};
grid[4] = {" ", " ", " ", "x", " ", " ", "x", " ", " ", " ", " "};
grid[5] = {" ", "x", " ", " ", " ", " ", " ", " ", " ", "x", "x"};
grid[6] = {" ", "x", "x", " ", " ", "x", "x", "x", "x", "x", "x"};
grid[7] = {" ", " ", "x", "x", " ", "x", " ", " ", " ", " ", " "};
grid[8] = {" ", " ", "x", "x", " ", " ", " ", " ", " ", " ", " "};
grid[9] = {" ", " ", "x", "x", " ", "x", " ", " ", " ", " ", " "};
grid[10] = {"x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x"};

startX = 1;
startY = 5;

endX = 11;
endY = 9;

printGrid(grid, startY, startX, endY, endX)

startSearch = {};
startDiscovered = {};
endSearch = {};
endDiscovered = {};

table.insert(startSearch, {startY, startX})
table.insert(endSearch, {endY, endX});
count = 0;
while not overlap(startDiscovered, endDiscovered) do
    tempCounter = #startSearch
    --[[tprint(startSearch);
    print();
    print (tempCounter); --]]
    for i=1, tempCounter do 
        local tempStartPY = {}
        local tempStartNY = {}
        local tempStartPX = {}
        local tempStartNX = {}
        local tempEndPY = {}
        local tempEndNY = {}
        local tempEndPX = {}
        local tempEndNX = {}
        --[[print("current list")
        tprint(startSearch)
        print()
        --]]
        print("searching form: " .. startSearch[1][1] .. ", " .. startSearch[1][2].. "\n");
        
        -- start search setup

        tempStartPY[1] = startSearch[1][1] + 1;
        tempStartPY[2] = startSearch[1][2];

        tempStartNY[1] = startSearch[1][1] - 1;
        tempStartNY[2] = startSearch[1][2];
        
        tempStartPX[1] = startSearch[1][1];
        tempStartPX[2] = startSearch[1][2] + 1
        
        tempStartNX[1] = startSearch[1][1];
        tempStartNX[2] = startSearch[1][2] - 1;


        -- end search setup

        tempEndPY[1] = endSearch[1][1] + 1;
        tempEndPY[2] = endSearch[1][2];

        tempEndNY[1] = endSearch[1][1] - 1;
        tempEndNY[2] = endSearch[1][2];
        
        tempEndPX[1] = endSearch[1][1];
        tempEndPX[2] = endSearch[1][2] + 1
        
        tempEndNX[1] = endSearch[1][1];
        tempEndNX[2] = endSearch[1][2] - 1;

        --[[print("current list")
        tprint(startSearch)
        print()
        --]]

        --start searching

        if tempStartPY[1] <= #grid and tempStartPY[2] <= #grid[tempStartPY[1]] then
            print("checking y of " .. tempStartPY[1] .. "and x of " .. tempStartPY[2])
            if  grid[tempStartPY[1]][tempStartPY[2]] ~= "x" and not discovered(startDiscovered, tempStartPY) then
                print("discovered in PY")
                print("added: " .. tempStartPY[1] .. ", " .. tempStartPY[2])
                grid[tempStartPY[1]][tempStartPY[2]] = "d";
                table.insert(startSearch, tempStartPY)
                --[[print("added coordenet")
                tprint(tempStartPY);
                print()
                startSearch[#startSearch + 1] = tempStartPY;
                print("current list")
                tprint(startSearch)
                --]]
                
            end
        end
        print("")
        --[[print("current list")
        tprint(startSearch)
        print()
        --]]
        if tempStartNY[1] > 0 and tempStartNY[2] <= #grid[tempStartNY[1]] then
            --[[print("current list")
            tprint(startSearch)
            print()
            --]]
            print("checking y of " .. tempStartNY[1] .. "and x of " .. tempStartNY[2])
            if  grid[tempStartNY[1]][tempStartNY[2]] ~= "x" and not discovered(startDiscovered, tempStartNY)then
                grid[tempStartNY[1]][tempStartNY[2]] = "d";
                print("discovered in NY")
                print("added: " .. tempStartNY[1] .. ", " .. tempStartNY[2]);
                table.insert(startSearch, tempStartNY)
                --[[print("added coordenet")
                tprint(tempStartNY);
                print()
                startSearch[#startSearch + 1] = tempStartNY;
                print("current list")
                tprint(startSearch)
                --]]
            end
        end

        if tempStartPX[1] <= #grid and tempStartPX[2] <= #grid[tempStartPX[1]]  then
            --[[print("current list")
            tprint(startSearch)
            print()
            --]]
            print("checking y of " .. tempStartPX[1] .. "and x of " .. tempStartPX[2])
            if  grid[tempStartPX[1]][tempStartPX[2]] ~= "x" and not discovered(startDiscovered, tempStartPX)then
                grid[tempStartPX[1]][tempStartPX[2]] = "d";
                print("discovered in PX")
                print("added: " .. tempStartPX[1] .. ", " .. tempStartPX[2]);
                table.insert(startSearch, tempStartPX)
                --[[print("added coordenet")
                tprint(tempStartPX);
                print()
                startSearch[#startSearch + 1] = tempStartPX;
                print("current list")
                tprint(startSearch)
                --]]
            end
        end

        if tempStartNX[2] > 0 and tempStartNX[2] <= #grid[tempStartNX[1]]  then
            --[[print("current list")
            tprint(startSearch)
            print()
            --]]
            print("checking y of " .. tempStartNX[1] .. "and x of " .. tempStartNX[2])
            if  grid[tempStartNX[1]][tempStartNX[2]] ~= "x" and not discovered(startDiscovered, tempStartNX)then
                grid[tempStartNX[1]][tempStartNX[2]] = "d";
                print("discovered in NX")
                print("added: " .. tempStartNX[1] .. ", " .. tempStartNX[2]);
                table.insert(startSearch, tempStartNX)
                --[[print("added coordenet")
                tprint(tempStartNX);
                print()
                startSearch[#startSearch + 1] = tempStartNX;
                print("current list")
                tprint(startSearch)
                --]]
            end
        end

        -- end searching
        --
        --
        --

        if tempEndPY[1] <= #grid and tempEndPY[2] <= #grid[tempEndPY[1]] then
            print("checking y of " .. tempEndPY[1] .. "and x of " .. tempEndPY[2])
            if  grid[tempEndPY[1]][tempEndPY[2]] ~= "x" and not discovered(endDiscovered, tempEndPY) then
                print("discovered in PY")
                print("added: " .. tempEndPY[1] .. ", " .. tempEndPY[2])
                grid[tempEndPY[1]][tempEndPY[2]] = "d";
                table.insert(endSearch, tempEndPY)
                --[[print("added coordenet")
                tprint(tempEndPY);
                print()
                endSearch[#endSearch + 1] = tempEndPY;
                print("current list")
                tprint(endSearch)
                --]]
                
            end
        end
        print("")
        --[[print("current list")
        tprint(endSearch)
        print()
        --]]
        if tempEndNY[1] > 0 and tempEndNY[2] <= #grid[tempEndNY[1]] then
            --[[print("current list")
            tprint(endSearch)
            print()
            --]]
            print("checking y of " .. tempEndNY[1] .. "and x of " .. tempEndNY[2])
            if  grid[tempEndNY[1]][tempEndNY[2]] ~= "x" and not discovered(endDiscovered, tempEndNY)then
                grid[tempEndNY[1]][tempEndNY[2]] = "d";
                print("discovered in NY")
                print("added: " .. tempEndNY[1] .. ", " .. tempEndNY[2]);
                table.insert(endSearch, tempEndNY)
                --[[print("added coordenet")
                tprint(tempEndNY);
                print()
                endSearch[#endSearch + 1] = tempEndNY;
                print("current list")
                tprint(endSearch)
                --]]
            end
        end

        if tempEndPX[1] <= #grid and tempEndPX[2] <= #grid[tempEndPX[1]]  then
            --[[print("current list")
            tprint(endSearch)
            print()
            --]]
            print("checking y of " .. tempEndPX[1] .. "and x of " .. tempEndPX[2])
            if  grid[tempEndPX[1]][tempEndPX[2]] ~= "x" and not discovered(endDiscovered, tempEndPX)then
                grid[tempEndPX[1]][tempEndPX[2]] = "d";
                print("discovered in PX")
                print("added: " .. tempEndPX[1] .. ", " .. tempEndPX[2]);
                table.insert(endSearch, tempEndPX)
                --[[print("added coordenet")
                tprint(tempEndPX);
                print()
                endSearch[#endSearch + 1] = tempEndPX;
                print("current list")
                tprint(endSearch)
                --]]
            end
        end

        if tempEndNX[2] > 0 and tempEndNX[2] <= #grid[tempEndNX[1]]  then
            --[[print("current list")
            tprint(endSearch)
            print()
            --]]
            print("checking y of " .. tempEndNX[1] .. "and x of " .. tempEndNX[2])
            if  grid[tempEndNX[1]][tempEndNX[2]] ~= "x" and not discovered(endDiscovered, tempEndNX)then
                grid[tempEndNX[1]][tempEndNX[2]] = "d";
                print("discovered in NX")
                print("added: " .. tempEndNX[1] .. ", " .. tempEndNX[2]);
                table.insert(endSearch, tempEndNX)
                --[[print("added coordenet")
                tprint(tempEndNX);
                print()
                endSearch[#endSearch + 1] = tempEndNX;
                print("current list")
                tprint(endSearch)
                --]]
            end
        end

        print("")
        table.insert(endDiscovered, endSearch[1])
        table.remove(endSearch, 1)
        table.insert(startDiscovered, startSearch[1]);
        table.remove(startSearch, 1);

    end    
    printGrid(grid, startY, startX, endY, endX)
    count = count + 1;
    
end


printGrid(grid, startY, startX, endY, endX)