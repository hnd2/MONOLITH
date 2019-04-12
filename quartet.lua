-- luacheck: ignore love LedMatrix
--------------------------------------------------
-- quartet


-- default mapping
local INPUT_TYPE_KEYBOARD = 'keyboard'
local INPUT_TYPE_JOYSTICK = 'joystick'
local INPUT_UP    = 'up'
local INPUT_LEFT  = 'left'
local INPUT_DOWN  = 'down'
local INPUT_RIGHT = 'right'
local INPUT_A     = 'a'
local INPUT_B     = 'b'
local INPUT_X     = 'x'
local INPUT_Y     = 'y'

local defaultInputSetting = {
    -- user1
    {
        type    = INPUT_TYPE_KEYBOARD,
        mapping = {
            [INPUT_UP]    = 'up',
            [INPUT_LEFT]  = 'left',
            [INPUT_DOWN]  = 'down',
            [INPUT_RIGHT] = 'right',
            [INPUT_A]     = 'z',
            [INPUT_B]     = 'x',
            [INPUT_X]     = 'c',
            [INPUT_Y]     = 'v',
        }
    },
    -- user2
    {
        type    = INPUT_TYPE_JOYSTICK,
        mapping = {
            [INPUT_UP]    = { 'axis0', reverse = false },
            [INPUT_LEFT]  = { 'axis1', reverse = false },
            [INPUT_DOWN]  = { 'axis0', reverse = true },
            [INPUT_RIGHT] = { 'axis1', reverse = true },
            [INPUT_A]     = 'a',
            [INPUT_B]     = 'b',
            [INPUT_X]     = 'x',
            [INPUT_Y]     = 'y',
        },
        option = {
            joystickName = 'unique-controller-name',
        }
    },
}


-- default options
local defaultOptions = {
    width = 128,
    height = 128,
    ledWidth = 64,
    ledHeight = 64,
    chains = 4,
    parallels = 1,
    windowScale = 1,
    targetFps = 60,
    pixelMapper = '',
    inputSetting = defaultInputSetting,
    inputAxisThresh = 0.5,
}


local q = {
    inited = false,
    os = 'unknown',
    ledMatrix = nil,
    width = 0,
    height = 0,
    options = {},
    canvas = nil,
    targetFps = 60,
    inputSetting = {},

    elapsedFrame = 0,
    prevDrawTime = 0.0,
    prevInputs = {},
}


--------------------------------------------------
-- init
-- @param options init options
function q.init(options)
    -- set options
    for key, value in pairs(defaultOptions) do
        if options ~= nil and options[key] ~= nil then
            q.options[key] = options[key]
        else
            q.options[key] = value
        end
    end

    q.width = q.options.width
    q.height = q.options.height
    q.windowScale = q.options.windowScale
    q.targetFps = q.options.targetFps
    q.canvas = love.graphics.newCanvas(
        q.width,
        q.height)

    -- init input history
    for user, userInputSetting in pairs(q.options.inputSetting) do
        q.setInputMapping(
            user,
            userInputSetting.type,
            userInputSetting.mapping,
            userInputSetting.options)
    end

    -- check os
    local fh, _ = io.popen('uname -o 2>/dev/null','r')
    if fh then
        q.os = fh:read()
    end

    -- init LedMatrix
    if q.os == 'GNU/Linux' then
        require "LedMatrix"
        q.ledMatrix = LedMatrix.new(
            q.ledWidth,
            q.ledHeight,
            q.chains,
            q.parallels,
            q.pixelMapper,
            1)
    end

    -- init window
    love.window.setMode(
        q.width * q.windowScale,
        q.height * q.windowScale,
        { resizable = false })


    q.inited = true
end

--------------------------------------------------
-- begin draw
function q.beginDraw()
    love.graphics.setCanvas(q.canvas)
    love.graphics.clear()
    love.graphics.push('all')
end


--------------------------------------------------
-- end draw.
-- send data to led matrix.
function q.endDraw()
    love.graphics.pop()

    -- draw canvas
    love.graphics.setCanvas()
    love.graphics.push('all')
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.scale(q.windowScale)
    love.graphics.draw(q.canvas)
    love.graphics.pop()

    -- send data to led matrix
    local image = q.canvas:newImageData()
    local data = image:getPointer()
    local size = image:getSize()
    if q.ledMatrix ~= nil then
        q.ledMatrix:setPixels(size, data)
        q.ledMatrix:swap();
    end

    -- update inputs
    for i, userInputSetting in ipairs(q.inputSetting) do
        for key, _ in pairs(userInputSetting.mapping) do
            local b = q.getButton(i, key)
            local prevValue = q.prevInputs[i][key]
            if b then
                if prevValue < 0 then
                    q.prevInputs[i][key] = 1
                else
                    q.prevInputs[i][key] = prevValue + 1
                end
            else
                if prevValue > 0 then
                    q.prevInputs[i][key] = -1
                else
                    q.prevInputs[i][key] = prevValue - 1
                end
            end
        end
    end

    -- stabilize fps
    if q.targetFps > 0.0 then
        local currentTime = love.timer.getTime()
        local waitTime =
            (1.0 / q.targetFps) - (currentTime - q.prevDrawTime)
        if waitTime > 0.0 then
            love.timer.sleep(waitTime)
        end
        q.prevDrawTime = love.timer.getTime()
    end
    q.elapsedFrame = q.elapsedFrame + 1
end

--------------------------------------------------
-- set input mapping.
-- @tparam int user user index
-- @tparam string type input type. ("keyboard" | "joystick")
-- @tparam table mapping input mapping
-- @tparam table options
function q.setInputMapping(user, type, mapping, options)
    -- clear history
    q.prevInputs[user] = {}
    for key, _ in pairs(mapping) do
        q.prevInputs[user][key] = 0
    end

    -- setting
    q.inputSetting[user] = {
        type = type,
        mapping = mapping,
        options = options,
    }
end

--------------------------------------------------
-- check button is down.
-- @tparam number user user index
-- @tparam object key button key
-- @return bool value
function q.getButton(user, key)
    local inputSetting = q.inputSetting[user]
    if inputSetting.type == INPUT_TYPE_KEYBOARD then
        return love.keyboard.isDown(inputSetting.mapping[key])
    elseif inputSetting.type == INPUT_TYPE_JOYSTICK then
        return false
    end
end

--------------------------------------------------
-- check button is just down.
-- @param user user index
-- @param key button key
-- @return bool value
function q.getButtonDown(user, key)
    return q.getButtonCount(user, key) == 1
        and q.getButton(user, key)
end

--------------------------------------------------
-- check button is just up.
-- @param user user index
-- @param key button key
-- @return bool value
function q.getButtonUp(user, key)
    return q.getButtonCount(user, key) == -1
        and (not q.getButton(user, key))
end

--------------------------------------------------
-- get button press or up count.
-- plus value is down, minus values is up count.
-- @param user user index
-- @param key button key
-- @return num counts
function q.getButtonCount(user, key)
    return q.prevInputs[user][key]
end

--------------------------------------------------
-- get axis value.
-- @param user user index
-- @param key button key
-- @return float value
function q.getAxis(user, key)
    local inputSetting = q.inputSetting[user]
    if inputSetting.type == INPUT_TYPE_KEYBOARD then
        if love.keyboard.isDown(inputSetting.mapping[key]) then
            return 1.0
        else
            return 0.0
        end
    elseif inputSetting.type == INPUT_TYPE_JOYSTICK then
        return 0.0
    end
end

return q

