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
            [INPUT_UP]    = { index = 0, type = 'axis', reverse = false },
            [INPUT_LEFT]  = { index = 1, type = 'axis', reverse = false },
            [INPUT_DOWN]  = { index = 0, type = 'axis', reverse = true },
            [INPUT_RIGHT] = { index = 1, type = 'axis', reverse = true },
            [INPUT_A]     = { index = 0, type = 'button' },
            [INPUT_B]     = { index = 1, type = 'button' },
            [INPUT_C]     = { index = 2, type = 'button' },
            [INPUT_D]     = { index = 3, type = 'button' },
        },
        options = {
            guid = '',
        },
    },
}
