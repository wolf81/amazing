local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')

local M = {}

local function new()
    local build = function(params)
        local map = Map()

        return map
    end

    return setmetatable({ build = build }, M)
end

return setmetatable(M, {
    __call = function(_, ...) return new(...) end,
})
