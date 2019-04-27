local M = {}

-- the base key for reading in the terrain data
-- this only includes the tiles used in chapter 11, any other maps added
-- will need to have the added tiles added to the key
key = {}
key["Peak"] = "k"
key["Mountain"] = "m"
key["Cliff"] = "c"
key["Lake"] = "l"
key["---"] = "-"
key["Plain"] = "p"
key["House"] = "h"
key["Village"] = "v"
key["Forest"] = "f"
key["Fort"] = "t"
key["Throne"] = "g"


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