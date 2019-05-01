local source_dir = love.filesystem.getSource()
package.cpath = package.cpath .. ';'
    .. source_dir .. '/monolith/?.so'

-- Monolith's core class
-- @classmod Monolith
local _M = {}
local mt = { __index = _M }

--------------------------------------------------
-- Input
-- @tfield Input input
_M.input = require('monolith.input')

--------------------------------------------------
-- InitOptions
-- @table InitOptions
-- @tfield[opt={128 128}] table resolution Game resolution.
-- @tfield[opt=1] number windowScale Window scale
-- @tfield[opt=60] number targetFps Target frame rate
-- @tfield[opt=true] boolean useCanvas If true, use canvas, else use screenshot
-- @tfield[opt={64 64}] table ledSize LED matrix board unit size
-- @tfield[opt=4] number ledChains LED matrix chains size
-- @tfield[opt=1] number ledParallels LED matrix parallels size
-- @tfield[opt='Z-mapper'] string ledPixelMapper LED matrix mapper name
-- @tfield[opt=1.0] number ledBrightness LED matrix brightness, range: 0.0 ~ 1.0
-- @tfield[opt=8] number ledColorBits LED matrix size of color bit, range: 1 ~ 8
-- @tfield[opt=true] boolean ledResetChip Reset LED matrix chip is enabled
-- @tfield[opt=true] boolean inputEnabled Input field is enabled
local InitOptions = {
  resolution       = { 128, 128 },
  windowScale      = 1,
  targetFps        = 60,
  useCanvas        = true,
  ledSize          = { 64, 64 },
  ledChains        = 4,
  ledParallels     = 1,
  ledPixelMapper   = 'Z-mapper',
  ledBrightness    = 1.0,
  ledColorBits     = 8,
  ledPwmNanoseconds = 100,
  ledResetChip     = true,
  inputEnabled     = true,
}

--------------------------------------------------
-- Constructor.
-- @tparam[opt] Monolith.InitOptions options Init options
-- @treturn Monolith Monolith instance
function _M.new(options)
  local object = {
    resolution = { 0, 0 },
    targetFps  = 0,
    ledMatrix  = nil,
    canvas     = nil,
    frameCount = 0,
    prevDrawTime = 0.0,
    input = nil,
  }

  -- set options
  if options == nil then
    options = {}
  end
  for key, value in pairs(InitOptions) do
    if options[key] == nil then
      options[key] = value
    end
  end

  -- check os
  local os
  local fh, _ = io.popen('uname -o 2>/dev/null','r')
  if fh then
    os = fh:read()
  end

  -- init led matrix
  if os == 'GNU/Linux' then
    require "LedMatrix"
    object.ledMatrix = LedMatrix.new({
        cols                = options.ledSize[1],
        rows                = options.ledSize[2],
        chain_length        = options.ledChains,
        parallel            = options.ledParallels,
        pixel_mapper_config = options.ledPixelMapper,
        pwm_lsb_nanoseconds = options.ledPwmNanoseconds,
        pwm_bits            = options.ledColorBits,
        brightness          = options.ledBrightness,
        reset_chip          = options.ledResetChip and 1 or 0,
      })
    -- object.ledMatrix.resetMatrix()
  end

  -- init window
  love.window.setMode(
    options.resolution[1] * options.windowScale,
    options.resolution[2] * options.windowScale,
    { resizable = false })

  -- init canvas
  if options.useCanvas then
    local canvas = love.graphics.newCanvas(
      options.resolution[1],
      options.resolution[2])
    canvas:setFilter('nearest')
    object.canvas = canvas
  end

  object.resolution = options.resolution
  object.targetFps = options.targetFps

  -- init input
  if options.inputEnabled then
    object.input = _M.input.new()
    local inputSettings = require("monolith.default_input_settings")
    for i, value in ipairs(inputSettings) do
      object.input:setUserSetting(i, value)
    end
  end

  return setmetatable(object, mt)
end

--------------------------------------------------
-- Begin draw.
function _M:beginDraw()
  if self.canvas ~= nil then
    love.graphics.setCanvas(self.canvas)
  end
  love.graphics.clear()
  love.graphics.push('all')
end

--------------------------------------------------
-- End draw.
-- Send image data to led matrix.
function _M:endDraw()
  love.graphics.pop()

  -- draw canvas
  if self.canvas ~= nil then
    love.graphics.setCanvas()
    love.graphics.push('all')
    love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
    love.graphics.scale(
      love.graphics.getWidth() / self.resolution[1],
      love.graphics.getHeight() / self.resolution[2])
    love.graphics.draw(self.canvas)
    love.graphics.pop()
  end

  -- send data to led matrix
  if self.ledMatrix ~= nil then
    local imageData = nil
    if self.canvas ~= nil then
      imageData = self.canvas:newImageData()
    else
      love.graphics.captureScreenshot(
      function(screenshot) imageData = screenshot end)
    end
    self:sendToLed(imageData)
  else
    if self.input ~= nil then
      self.input:update()
    end
  end

  -- stabilize fps
  if self.targetFps > 0.0 then
    local currentTime = love.timer.getTime()
    local waitTime =
    (1.0 / self.targetFps) - (currentTime - self.prevDrawTime)
    if waitTime > 0.0 then
      love.timer.sleep(waitTime)
    end
    self.prevDrawTime = love.timer.getTime()
  end
  self.frameCount = self.frameCount + 1
end

--------------------------------------------------
-- Send image data to LED matrix.
-- @tparam love.ImageData imageData
function _M:sendToLed(imageData)
  -- update input
  if self.input ~= nil then
    self.input:update()
  end

  if self.ledMatrix == nil then
    return
  end

  self.ledMatrix:setPixels(
    imageData:getSize(),
    imageData:getPointer())
  self.ledMatrix:swap();
end

--------------------------------------------------
-- Get resolution.
-- @treturn number x
-- @treturn number y
function _M:getResolution()
  return unpack(self.resolution)
end

--------------------------------------------------
-- Get width.
-- @treturn number width
function _M:getWidth()
  return self.resolution[1]
end

--------------------------------------------------
-- Get height.
-- @treturn number height
function _M:getHeight()
  return self.resolution[2]
end

--------------------------------------------------
-- Get elapsed frame count.
-- @treturn number frame count
function _M:getFrameCount()
  return self.frameCount
end

return _M
