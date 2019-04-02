--[[
Last Author: Dylan Cyphers
Last Edit: 2/17/19
--]]

function Init()
    return joypad.get(1)
end

function NextInput(frames)
    --gba runs at 60 fps
    --a value of 2 is a frame-perfect input (useful for fast menu)
    --a value of 60 is the generic wait time
    --a value of 120 is a longer wait time to account for game animations
    for i = 1, frames, 1 
    do
        vba.frameadvance()
    end
end

function Press(button, frames)
    buttons[button] = 1 --declare the button to press
    joypad.set(1, buttons) --actually press it
    buttons[button] = false --depress it
    NextInput(frames) --delay time between multiple presses
end

function Rename()
    --Name: Kaga495, January, Male

    --skipping text
    Press("A", 60)

    --make tactician
    Press("A", 120)

    --skipping text
    Press("A", 60)

    --enter information
    Press("A", 60)

    --select name
    Press("A", 60)

    --clear name box
    for i = 1, 5, 1 --"Mark_" is the default name
    do
        Press("B", 2)
    end

    --move cursor to "K" and press it
    for i = 1, 10, 1 --"K" is 10 spaces to the right
    do
        Press("right", 2)
    end
    Press("A", 2)

    --move cursor to "a" and press it
    for i = 1, 10, 1  --"a" is 10 to the left
    do
        Press("left", 2)
    end
    for i = 1, 2, 1 --"a" is 2 down
    do
        Press("down", 2)
    end
    Press("A", 2)

    --move cursor to "g" and press it
    for i = 1, 6, 1 --"g" is 6 to the right
    do 
        Press("right", 2)
    end
    Press("A", 2)

    --move cursor to "a" and press it
    for i = 1, 6, 1 --"a" is 6 to the left
    do
        Press("left", 2)
    end
    Press("A", 2)

    --move cursor to "4" and press it
    for i = 1, 3, 1 --"4" is 3 to the right
    do 
        Press("right", 2)
    end
    for i = 1, 2, 1 --"4" is 2 down
    do
        Press("down", 2)
    end
    Press("A", 2)

    --move cursor to "9" and press it
    for i = 1, 5, 1 --"9" is 5 to the right
    do
        Press("right", 2)
    end
    Press("A", 2)

    --move cursor to "5" and press it
    for i = 1, 4, 1 --"5" is 4 to the left
    do
        Press("left", 2)
    end
    Press("A", 2)

    --cursor automatically goes to "OK!"
    Press("A", 60)

    --finalize creation 
    Press("start", 60) --get the menu up
    Press("A", 60) --skip the line text
    Press("A", 60) --actually say Yes
end

function NewGame()
    --wait until you can input once after "powering on"
    NextInput(120)

    --get to main menu
    Press("start", 120) --skipping opening cutscene
    Press("start", 60) --"press start" screen

    --make new game
    Press("A", 60)

    --move to Eliwood
    Press("left", 60)
    
    --select Eliwood
    Press("A", 120)

    --confirm/save
    Press("A", 120)

    Rename()

    Press("start", 60)

end

--[[
function Restart(buttons)
    --wait until you can input once after "powering on"
    NextInput(120)

    --get to main menu
    Press(buttons, "start", 120) --skipping opening cutscene
    Press(buttons, "start", 60) --"press start" screen

    Press(buttons, "A", 60) --select "Restart Chapter"
    Press(buttons, "A", 60) --select the first slot
end

function SetConfig(buttons) 
    --For convenience, take off animations and increase dialgoue speed
    Press(buttons, "up", 30) --select an empty tile
    Press(buttons, "A", 2) --opens the menu
    Press(buttons, "down", 2) --move the cursor to "Options"
    Press(buttons, "down", 2)
    Press(buttons, "A", 30) --actually enter the options

    --Inside options now
    Press(buttons, "right", 2) --set animation to "OFF"
    Press(buttons, "right", 2)
    Press(buttons, "down", 2) --go to "Game Speed"

    Press(buttons, "right", 2) --set it to "Fast"
    Press(buttons, "down", 2) --go to "Text Speed"

    Press(buttons, "right", 2) --set it to "Max"
    Press(buttons, "right", 2)

    Press(buttons, "B", 30) --exiting the menu
    Press(buttons, "L", 2) --reselect the main lord
end

function PreChapterStart(buttons)
    --Setup for entering the chapter
    Press(buttons, "start", 360) --skip cutscene; waiting extra long for the "transition" time
    Press(buttons, "start", 120) --skip the ending half of said transition (eats inputs too early)
    Press(buttons, "start", 120) --skip dialogue; PLAYER PHASE 1!
end

function Ch11(buttons)

    PreChapterStart(buttons)

    --Player Phase 1
    SetConfig(buttons)
    --Select Lowen
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him to the right of bandit
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "right", 2)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 240) --actually attack

    --Select Rebecca
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move her below Lowen
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 180) --actually attack

    --Select Eliwood
    Press(buttons, "L", 2) 
    Press(buttons, "A", 4)
    --Move him below bandit
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 240) --actually attack

    --Select Marcus
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him below fort
    Press(buttons, "right", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "up", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 60)
    Press(buttons, "down", 2)
    Press(buttons, "A", 2) --select "Wait"

    --Enemy Phase 1
    NextInput(800) --nothing you can really do to speed it up
    --Skip dialogue
    Press(buttons, "start", 120)
    
    --Player Phase 2
    --Select Bartre
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him next to archer
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 30) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 180) --actually attack

    --Select Rebecca 
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move her on the fort
    Press(buttons, "left", 2)
    Press(buttons, "up", 2)
    Press(buttons, "left", 2)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 240) --actually attack

    --Select Dorcas
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him to the village
    Press(buttons, "up", 30)
    Press(buttons, "A", 30)
    Press(buttons, "A", 60)
    Press(buttons, "start", 240)

    --Select Marcus
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him above far forest
    Press(buttons, "up", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "down", 30)
    Press(buttons, "A", 60)
    Press(buttons, "down", 2)
    Press(buttons, "A", 30) --select "Wait"

    --Select Lowen
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --move him bottom left tile
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "down", 30)
    Press(buttons, "A", 60)
    Press(buttons, "down", 2)
    Press(buttons, "A", 30) --select "Wait"

    --Select Eliwood
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    Press(buttons, "up", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 60)
    Press(buttons, "down", 2)
    Press(buttons, "down", 2)
    Press(buttons, "A", 30) --select "Wait"

    --Enemy Phase 2
    NextInput(900) --nothing you can really do to speed it up

    --Player Phase 3
    
    --Select Lowen
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him next to the bandit
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 30) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 240) --actually attack
    
    --Select Marcus
    Press(buttons, "L", 30) --Note: have to wait additional time for having the screen move
    Press(buttons, "L", 30)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him next to the far left bandit
    Press(buttons, "left", 2)
    Press(buttons, "down", 2)
    Press(buttons, "left", 2)
    Press(buttons, "down", 2)
    Press(buttons, "left", 2)
    Press(buttons, "down", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 60) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 240) --actually attack

    --Select Eliwood
    Press(buttons, "L", 30)
    Press(buttons, "L", 30)
    Press(buttons, "L", 2)
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him to the forest
    Press(buttons, "down", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 60)
    Press(buttons, "down", 2)
    Press(buttons, "A", 30) --select "Wait"

    --End turn
    Press(buttons, "A", 30)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30)

    --Enemy Phase 3
    NextInput(1100) --nothing you can really do to speed it up

    --Player Phase 4
    --Select Eliwood
    Press(buttons, "A", 4)
    --Move him left of archer
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "down", 30)
    Press(buttons, "A", 60) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 240) --actually attack

    --Select Marcus
    Press(buttons, "L", 2)
    Press(buttons, "A", 4)
    --Move him below boss
    Press(buttons, "left", 2)
    Press(buttons, "left", 30)
    Press(buttons, "A", 60) --move unit here and wait for animation
    Press(buttons, "A", 30) --select weapon
    Press(buttons, "A", 30) --look at combat window
    Press(buttons, "A", 120) --actually attack
    --Skip attack dialogue
    Press(buttons, "start", 240)
    --Skip death dialogue
    Press(buttons, "start", 180)

    --End turn
    Press(buttons, "A", 30)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30)

    NextInput(100) --Wait some frames
    
    --Player Phase 5 (No enemies on map; no Enemy Phase 4)
    --Select Eliwood
    Press(buttons, "A", 4)
    Press(buttons, "down", 2)
    Press(buttons, "left", 2)
    Press(buttons, "left", 2)
    Press(buttons, "up", 30)
    Press(buttons, "A", 30) --enter menu
    Press(buttons, "A", 2) --select seize (ends the chapter)
end

--]]

buttons = Init()
NewGame()

--Restart(buttons)
--Ch11(buttons)