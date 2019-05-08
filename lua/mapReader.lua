local M = {}

-- the base key for reading in the terrain data
-- this only includes the tiles used in chapter 11, any other maps added
-- will need to have the added tiles added to the key
stringToShort = {}
stringToShort["Peak"] = "k"
stringToShort["Mountain"] = "m"
stringToShort["Cliff"] = "c"
stringToShort["Lake"] = "l"
stringToShort["---"] = "-"
stringToShort["Plain"] = "p"
stringToShort["House"] = "h"
stringToShort["Village"] = "v"
stringToShort["Forest"] = "f"
stringToShort["Fort"] = "t"
stringToShort["Throne"] = "g"

shortToString = {}
shortToString["k"] = "Peak"
shortToString["m"] = "Mountain"
shortToString["c"] = "Cliff"
shortToString["l"] = "Lake"
shortToString["-"] = "---"
shortToString["p"] = "Plain"
shortToString["h"] = "House"
shortToString["v"] = "Village"
shortToString["f"] = "Forest"
shortToString["t"] = "Fort"
shortToString["g"] = "Throne"


function setupMap()
    rows = 12
    cols = 18
    map = {}

    for i=1, rows, 1 
    do
        map[i] = {}
        for j=1, cols, 1 
        do
            map[i][j] = {}
        end
    end

    file = io.open("11.txt", "r")

    io.input(file)

    --stringname:sub(5,5) gets the 5th char in the string

    for i=1, rows, 1
    do
        map[i] = {}
        the_row = io.read()
        for j=1, cols, 1
        do
            map[i][j] = {the_row:sub(j,j), 0}
        end
    end

    io.close(file)
    return map
end

function QuickPrint(T)
    for i,v in ipairs(T) 
    do 
        print(i,v) 
    end 
end

--QuickPrint(map)

M.map = map;
M.shortToString = shortToString;
M.stringToShort = stringToShort;
M.setupMap = setupMap;

return M;