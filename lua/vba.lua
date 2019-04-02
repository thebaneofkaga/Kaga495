local M = {}

function Init()
    return joypad.get(1)
end

buttons = Init()

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


M.Init = Init
M.buttons = buttons
M.NextInput = NextInput
M.Press = Press

return M