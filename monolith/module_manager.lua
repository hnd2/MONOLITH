local _M = {}
local _mt = { __index = _M }
local source_dir = love.filesystem.getSource()

function _M.addPath(path)
  package.path = package.path
    .. ';' .. source_dir .. '/' .. path .. '/?.lua'
    .. ';' .. source_dir .. '/' .. path .. '/?/init.lua'
end

function _M.addCpath(path)
  package.cpath = package.cpath
    .. ';' .. source_dir .. '/' .. path .. '/?.so'
end

function _M.addModulePath(path)
  _M.addPath(path .. '/share/lua/5.1')
  _M.addCpath(path .. '/share/lua/5.1')
end

return _M
