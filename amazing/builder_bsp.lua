local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local N_TRIES = 240

local BSPBuilder = {}
BSPBuilder.__index = BuilderBase

local function getRandomSubrect(rect)
    local rect_w = math.abs(rect.x1 - rect.x2)
    local rect_h = math.abs(rect.y1 - rect.y2)

    local w = math.max(2, random(1, math.min(10, rect_w)) - 1) + 1
    local h = math.max(2, random(1, math.min(10, rect_h)) - 1) + 1

    return Rect(
        rect.x1 + random(1, 6) - 1,
        rect.y1 + random(1, 6) - 1,
        w,
        h
    )
end

local function isPossible(rect, map)
    local x1, x2 = rect.x1 - 1, rect.x2 + 2
    local y1, y2 = rect.y1 - 1, rect.y2 + 2

    local map_w, map_h = map.size()

    local can_build = true

    for y = y1, y2 do        
        for x = x1, x2 do
            if x > map_w then can_build = false; break end
            if x < 1 then can_build = false; break end
            if y > map_h then can_build = false; break end
            if y < 1 then can_build = false; break; end

            if bit.band(map.get(x, y), Tile.WALL) ~= Tile.WALL then
                can_build = false
            end
        end
    end

    return can_build
end

local function addSubrects(rects, rect)
    local w = math.abs(rect.x1 - rect.x2)
    local h = math.abs(rect.y1 - rect.y2)
    local half_w = math.floor(math.max(w / 2, 1))
    local half_h = math.floor(math.max(h / 2, 1))

    rects[#rects + 1] = Rect(rect.x1, rect.y1, half_w, half_w)
    rects[#rects + 1] = Rect(rect.x1, rect.y1 + half_h, half_w, half_h)
    rects[#rects + 1] = Rect(rect.x1 + half_w, rect.y1, half_w, half_h)
    rects[#rects + 1] = Rect(rect.x1 + half_w, rect.y1 + half_h, half_w, half_h)
end

local function getRandomRect(rects)
   return rects[random(#rects)]
end

function BSPBuilder:build(params)
    local map = Map()

    local rooms = {}

    local map_w, map_h = map.size()

    local rects = {}
    rects[#rects + 1] = Rect(1, 1, map_w - 2, map_h - 2)

    local first_room = rects[1]
    addSubrects(rects, first_room)

    for _ = 1, N_TRIES do
        local rect = getRandomRect(rects)
        local candidate = getRandomSubrect(rect)

        if isPossible(candidate, map) then
            applyRoom(map, candidate)
            rooms[#rooms + 1] = rect
            addSubrects(rects, rect)
        end
    end

    return map
end

return BSPBuilder
