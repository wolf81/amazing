local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local BSPBuilder = {}
BSPBuilder.__index = BuilderBase

local function getRandomSubrect()
    -- body
end

local function getRandomRect(rect)
    -- body
end

local function isPossible(room)
    return true
end

function BSPBuilder:build(params)
    return Map()

    --[[
    local build = function(params)
        local map = Map()
        local map_w, map_h = map.size()

        local rects = {}
        rects[#rects + 1] = Rect(2, 2, map_w - 5, map_h - 5)

        local first_room = rects[1]
        local n_rooms = 0

        while n_rooms < 240 do
            local rect = getRandomRect(rect)
            local candidate = getRandomSubrect(rect)

            if isPossible(candidate) then

            end
        end

        return map
    end

    return setmetatable({ build = build }, M)
    --]]
end

return BSPBuilder