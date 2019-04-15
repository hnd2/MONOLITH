MONOLITH Library
---------------
### Basic
```lua
local Monolith = require("monolith.core")
local monolith = nil
local players = {}

--------------------------------------------------
local Player = { index = 1 }
function Player.new()
  local object = {
    index = Player.index,
    x = 0,
    y = 0,
  }
  Player.index = Player.index + 1
  return setmetatable(
      object,
      { __index = Player })
end

function Player:draw()
  if monolith.input:getButton(self.index, 'up') then
    self.y = self.y - 1
  elseif monolith.input:getButton(self.index, 'down') then
    self.y = self.y + 1
  end
  if monolith.input:getButton(self.index, 'left') then
    self.x = self.x - 1
  elseif monolith.input:getButton(self.index, 'right') then
    self.x = self.x + 1
  end
  if monolith.input:getButtonDown(self.index, 'a') then
    love.graphics.setColor(1, 0, 0, 1)
  else
    love.graphics.setColor(1, 1, 0, 1)
  end
  love.graphics.rectangle('fill', self.x, self.y, 10, 10)
end

--------------------------------------------------
function love.load()
  monolith = Monolith.new()
  table.insert(players, Player.new())
  table.insert(players, Player.new())
end

--------------------------------------------------
function love.draw()
  monolith:beginDraw()
  for _, player in ipairs(players) do
      player:draw()
  end
  monolith:endDraw()
end
```

### Custom draw
```lua
local monolith = require("monolith.core").new()

function love.draw()
    love.graphics.captureScreenshot(monolith.sendToLed)
end
```

### Custom input

詳細は[monolith/default_input_settings.lua](../monolith/default_input_settings.lua)を参照.

```lua
local monolith = require("monolith.core").new()
local user_setting = {
    type     = 'keyboard',
    mapping  = {
        fire = 'z',
        jump = 'x',
    },
}
monolith.input:setUserSetting(1, user_setting)

function love.draw()
    local b1 = monolith.input:getButton(1, 'fire')
    local b2 = monolith.input:getButton(1, 'jump')
    love.graphics.print(tostring(b1) .. ', ' .. tostring(b2))
end
```

