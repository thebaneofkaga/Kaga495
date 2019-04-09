local M = {}

-- the base key for reading in the terrain data
-- this only includes the tiles used in chapter 11, any other maps added
-- will need to have the added tiles added to the key
key = {}
key["k"] = "Peak"
key["m"] = "Mountain"
key["c"] = "Cliff"
key["l"] = "Lake"
key["-"] = "---"
key["p"] = "Plain"
key["h"] = "House"
key["v"] = "Village"
key["f"] = "Forest"
key["t"] = "Fort"
key["g"] = "Throne"


rows = 12
cols = 18
map = {}

for i=1, rows, 1 
do
    map[i] = {}
    for j=1, cols, 1 
    do
        map[i][j] = 0
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
        map[i][j] = the_row:sub(j,j)
    end
end

io.close(file)

function QuickPrint(T)
    for i,v in ipairs(T) 
    do 
        print(i,v) 
    end 
end

--QuickPrint(map)

M.map = map;
M.key = key;

return M;