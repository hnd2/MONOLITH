--------------------------------------------------
-- Multi device input manager
-- @classmod Input
local _M = {}
local mt = { __index = _M }

--------------------------------------------------
local Constants = {}
--- 'keyboard'
-- @tfield string KEYBOARD 'keyboard'
Constants.TYPE_KEYBOARD = 'keyboard'
--- 'joystick'
-- @tfield string JOYSTICK 'joystick'
Constants.TYPE_JOYSTICK = 'joystick'

--------------------------------------------------
-- User setting
-- @table UserSetting
-- @tfield[opt=Constants.TYPE_KEYBOARD] string type Controller type
-- @tfield table mapping axis/button mapping.
UserSetting = {
    type    = Constants.TYPE_KEYBOARD,
    mapping = {}
}



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
-- @tparam int user user index
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
-- Get button is down.
-- @tparam number user user index
-- @tparam object key button key
-- @return bool value
function _M:getButton(user, key)
    local userSetting = self.userSettings[user]
    if userSetting == nil then
        error('user[' .. tostring(user) .. '] setting is not set.')
    end
    if userSetting.type == Constants.TYPE_KEYBOARD then
        return love.keyboard.isDown(userSetting.mapping[key])
    elseif userSetting.type == Constants.TYPE_JOYSTICK then
        return false
    end
end

--------------------------------------------------
-- Get button is just down.
-- @param user user index
-- @param key button key
-- @return bool value
function _M:getButtonDown(user, key)
    return self:getButtonCount(user, key) < 0
        and self:getButton(user, key)
end

--------------------------------------------------
-- Get button is just up.
-- @param user user index
-- @param key button key
-- @return bool value
function _M:getButtonUp(user, key)
    return self:getButtonCount(user, key) > 0
        and (not self:getButton(user, key))
end

--------------------------------------------------
-- Get button down/up count.
-- Plus value is down, minus values is up.
-- @param user user index
-- @param key button key
-- @return num counts
function _M:getButtonCount(user, key)
    return self.prevInputs[user][key]
end

--------------------------------------------------
-- Get axis value.
-- @param user user index
-- @param key button key
-- @return float value, range: -1.0 ~ 1.0
function _M:getAxis(user, key)
    local userSetting = self.userSettings[user]
    if userSetting.type == input.TYPE_KEYBOARD then
        if love.keyboard.isDown(userSetting.mapping[key]) then
            return 1.0
        else
            return 0.0
        end
    elseif userSetting.type == input.TYPE_JOYSTICK then
        return 0.0
    end
end

return _M
