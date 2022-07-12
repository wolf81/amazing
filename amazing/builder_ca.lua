local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local CABuilder = {}
CABuilder.__index = BuilderBase

function CABuilder:build(params)
    local map = Map()

    local map_w, map_h = map.size()

    for y = 1, map_h do
        for x = 1, map_w do
            if random(1, 100) > 55 then
                map.set(x, y, Tile.FLOOR)
            end
        end
    end

    return map
end

return CABuilder
