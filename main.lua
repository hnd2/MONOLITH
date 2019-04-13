local Monolith = require("monolith.core")
local monolith = Monolith.new({windowScale = 4})

function love.load()
end

function love.draw()
    monolith:beginDraw()
    monolith:endDraw()
    love.graphics.print(tostring(monolith.input:getButtonCount(1, 'up')))
end
