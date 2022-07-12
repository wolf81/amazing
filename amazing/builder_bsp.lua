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

    local w = math.max(3, random(1, math.min(10, rect_w)))
    local h = math.max(3, random(1, math.min(10, rect_h)))

    return Rect(
        rect.x1 + random(1, 6) - 1,
        rect.y1 + random(1, 6) - 1,
        w,
        h
    )
end

local function isPossible(rect, map)
    local ext_rect = rect.copy().inset(-1, -1, 1, 1)
    local map_w, map_h = map.size()

    if ext_rect.x1 < 1 then return false end
    if ext_rect.x2 > map_w then return false end
    if ext_rect.y1 < 1 then return false end
    if ext_rect.y2 > map_h then return false end

    for y = ext_rect.y1, ext_rect.y2 do        
        for x = ext_rect.x1, ext_rect.x2 do
            if bit.band(map.get(x, y), Tile.WALL) ~= Tile.WALL then
                return false
            end
        end
    end

    return true
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
   return rects[random(#rects)].copy()
end

local function getRandomPosition(rect)
    local x = rect.x1 + random(0, math.abs(rect.x1 - rect.x2))
    local y = rect.y1 + random(0, math.abs(rect.y1 - rect.y2))
    return x, y
end

local function addCorridor(map, x1, y1, x2, y2)
    local x, y = x1, y1

    while (x ~= x2 or y ~= y2) do
        if x < x2 then
            x = x + 1
        elseif x > x2 then
            x = x - 1
        elseif y < y2 then
            y = y + 1
        elseif y > y2 then
            y = y - 1
        end

        map.set(x, y, Tile.FLOOR)
    end
end

function BSPBuilder:build(params)
    print('build bsp')

    local map = Map()

    local rooms = {}

    local map_w, map_h = map.size()

    local rects = {}
    local rect = Rect(1, 1, map_w - 2, map_h - 2)
    rects[#rects + 1] = rect
    addSubrects(rects, rects[1])

    for _ = 1, N_TRIES do
        local rect = getRandomRect(rects)
        local candidate = getRandomSubrect(rect)

        if isPossible(candidate, map) then
            applyRoom(map, candidate)
            rooms[#rooms + 1] = candidate
            addSubrects(rects, rect.copy())
        end
    end

    for i = 1, #rooms - 1 do
        local room = rooms[i]
        local next_room = rooms[i + 1]

        local start_x, start_y = getRandomPosition(room)
        local end_x, end_y = getRandomPosition(next_room)

        addCorridor(map, start_x, start_y, end_x, end_y)
    end

    local stair_x, stair_y = rooms[#rooms].center()
    map.set(stair_x, stair_y, Tile.STAIR_DN)

    stair_x, stair_y = rooms[1].center()
    map.set(stair_x, stair_y, Tile.STAIR_UP)

    return map
end

return BSPBuilder
