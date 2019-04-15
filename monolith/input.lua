--------------------------------------------------
-- Multi device input manager
-- @classmod Input
local _M = {}
local mt = { __index = _M }

--------------------------------------------------
local Constants = {}
--- 'keyboard'
-- @tfield string INPUT_TYPE_KEYBOARD 'keyboard'
Constants.INPUT_TYPE_KEYBOARD = 'keyboard'
--- 'joystick'
-- @tfield string INPUT_TYPE_JOYSTICK 'joystick'
Constants.INPUT_TYPE_JOYSTICK = 'joystick'
--- 'axis'
-- @tfield string JOYSTICK_INPUT_TYPE_AXIS 'axis'
Constants.JOYSTICK_INPUT_TYPE_AXIS = 'axis'
--- 'button'
-- @tfield string JOYSTICK_INPUT_TYPE_BUTTON 'button'
Constants.JOYSTICK_INPUT_TYPE_BUTTON = 'button'

--------------------------------------------------
-- User setting
-- @table UserSetting
-- @tfield[opt=Constants.TYPE_KEYBOARD] string type Controller type
-- @tfield table mapping axis/button mapping
-- @tfield table options type specific options
local UserSetting = {
    type    = Constants.TYPE_KEYBOARD,
    mapping = {},
    options = {},
}

--------------------------------------------------
local function getJoystick(userSetting)
    local guid = userSetting.options.guid
    local name = userSetting.options.name
    if guid == nil and name == nil then
        error('Joystick setting needs contain guid or name')
    end
    local joysticks = love.joystick.getJoysticks()
    for _, joystick in ipairs(joysticks) do
        if joystick:getGUID() == guid
            or joystick:getName() == name then
            return joystick
        end
    end
    return nil
end

--------------------------------------------------
local function getJoystickValue(joystick, userSetting, key)
    local map = userSetting.mapping[key]
    if map == nil then
        error('Joystick mapping do not contains key: ' .. key)
    end
    local value = 0.0
    local index = map.index
    if map.type == Constants.JOYSTICK_INPUT_TYPE_AXIS then
        value = joystick:getAxis(index)
    elseif map.type == Constants.JOYSTICK_INPUT_TYPE_BUTTON then
        if joystick:isDown(index) then
            value = 1.0
        else
            value = 0.0
        end
    else
        error('Invalid joystick type: ' .. key.type)
    end
    if map.reverse then
        value = value * -1
    end
    return value
end

--------------------------------------------------
-- Constructor
-- @treturn input Input instance
function _M.new()
    local object = {
        userSettings = {},
        prevInputs = {},
    }
    
    return setmetatable(object, mt)
end

--------------------------------------------------
function _M:__tostring()
    return 'monolith.input {' + self + '}'
end

--------------------------------------------------
--- Update input history
function _M:update()
    -- update inputs
    for i, userSetting in ipairs(self.userSettings) do
        for key, _ in pairs(userSetting.mapping) do
            local prevValue = self.prevInputs[i][key]
            if self:getButton(i, key) then
                if prevValue < 0 then
                    self.prevInputs[i][key] = 1
                else
                    self.prevInputs[i][key] = prevValue + 1
                end
            else
                if prevValue > 0 then
                    self.prevInputs[i][key] = -1
                else
                    self.prevInputs[i][key] = prevValue - 1
                end
            end
        end
    end
end

--------------------------------------------------
-- Set user input mapping.
-- @tparam number user user index
-- @tparam Input.UserSetting setting user setting
function _M:setUserSetting(user, setting)
    -- clear history
    self.prevInputs[user] = {}
    for key, _ in pairs(setting.mapping) do
        self.prevInputs[user][key] = 0
    end

    self.userSettings[user] = setting
end

--------------------------------------------------
-- Get input is available
-- @tparam number user user index
-- @treturn boolean value
function _M:isAvailable(user)
    local userSetting = self.userSettings[user]
    if userSetting.type == Constants.INPUT_TYPE_KEYBOARD then
        return true
    elseif userSetting.type == Constants.INPUT_TYPE_JOYSTICK then
        return getJoystick(userSetting) ~= nil
    end
end

--------------------------------------------------
-- Get button is down.
-- @tparam number user user index
-- @tparam string key button key
-- @treturn boolean value
function _M:getButton(user, key)
    local userSetting = self.userSettings[user]
    if userSetting == nil then
        error('user[' .. tostring(user) .. '] setting is not set.')
    end
    if userSetting.type == Constants.INPUT_TYPE_KEYBOARD then
        return love.keyboard.isDown(userSetting.mapping[key])
    elseif userSetting.type == Constants.INPUT_TYPE_JOYSTICK then
        local joystick = getJoystick(userSetting)
        if joystick == nil then
            return false
        end
        local value = getJoystickValue(joystick, userSetting, key)
        return value > 0.5
    end
end


--------------------------------------------------
-- Get button is just down.
-- @tparam number user user index
-- @tparam string key button key
-- @treturn boolean value
function _M:getButtonDown(user, key)
    return self:getButtonCount(user, key) < 0
        and self:getButton(user, key)
end

--------------------------------------------------
-- Get button is just up.
-- @tparam number user user index
-- @tparam number key button key
-- @treturn boolean value
function _M:getButtonUp(user, key)
    return self:getButtonCount(user, key) > 0
        and (not self:getButton(user, key))
end

--------------------------------------------------
-- Get button down/up count.
-- Plus value is down, minus values is up.
-- @tparam number user user index
-- @tparam string key button key
-- @treturn number num counts
function _M:getButtonCount(user, key)
    return self.prevInputs[user][key]
end

--------------------------------------------------
-- Get axis value.
-- @tparam number user user index
-- @tparam string key button key
-- @treturn float value, range: -1.0 ~ 1.0
function _M:getAxis(user, key)
    local userSetting = self.userSettings[user]
    if userSetting.type == Constants.INPUT_TYPE_KEYBOARD then
        if love.keyboard.isDown(userSetting.mapping[key]) then
            return 1.0
        else
            return 0.0
        end
    elseif userSetting.type == Constants.INPUT_TYPE_JOYSTICK then
        local joystick = getJoystick(userSetting)
        if joystick == nil then
            return false
        end
        return getJoystickValue(joystick, userSetting, key)
    end
end

return _M
