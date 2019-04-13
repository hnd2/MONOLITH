local INPUT_UP    = 'up'
local INPUT_LEFT  = 'left'
local INPUT_DOWN  = 'down'
local INPUT_RIGHT = 'right'
local INPUT_A     = 'a'
local INPUT_B     = 'b'
local INPUT_C     = 'c'
local INPUT_D     = 'd'

return {
    -- user1
    {
        type    = 'keyboard',
        mapping = {
            [INPUT_UP]    = 'up',
            [INPUT_LEFT]  = 'left',
            [INPUT_DOWN]  = 'down',
            [INPUT_RIGHT] = 'right',
            [INPUT_A]     = 'z',
            [INPUT_B]     = 'x',
            [INPUT_C]     = 'c',
            [INPUT_D]     = 'v',
        },
    },
    -- user2
    {
        type    = 'joystick',
        mapping = {
            [INPUT_UP]    = { 'axis0', reverse = false },
            [INPUT_LEFT]  = { 'axis1', reverse = false },
            [INPUT_DOWN]  = { 'axis0', reverse = true },
            [INPUT_RIGHT] = { 'axis1', reverse = true },
            [INPUT_A]     = 'a',
            [INPUT_B]     = 'b',
            [INPUT_C]     = 'x',
            [INPUT_D]     = 'y',
        },
        options = {
            joystickName = 'unique-controller-name',
        },
    },
}
