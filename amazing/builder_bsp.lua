local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local N_TRIES = 240
local ROOM_SIZE_MIN = 5
local ROOM_SIZE_MAX = 10

--[[ BINARY SPACE PARTITION BUILDER ]]--

local BSPBuilder = {}
BSPBuilder.__index = BuilderBase

-- return a random sub rectangle from a larger rectangle
local function getRandomSubrect(rect)
    local rect_w = math.abs(rect.x1 - rect.x2)
    local rect_h = math.abs(rect.y1 - rect.y2)

    local w = math.max(ROOM_SIZE_MIN, random(1, math.min(ROOM_SIZE_MAX, rect_w))) - 1
    local h = math.max(ROOM_SIZE_MIN, random(1, math.min(ROOM_SIZE_MAX, rect_h))) - 1

    return Rect(
        rect.x1 + random(1, 6) - 1,
        rect.y1 + random(1, 6) - 1,
        w,
        h
    )
end

-- make sure a rectangle is not overlapping another room
-- we check this by making sure each tile is a wall tile
local function isPossible(rect, map, rooms)
    local ext_rect = rect.copy().inset(-1, -1, 1, 1)
    local map_w, map_h = map.size()

    if ext_rect.x1 < 1 then return false end
    if ext_rect.x2 > map_w then return false end
    if ext_rect.y1 < 1 then return false end
    if ext_rect.y2 > map_h then return false end

    for _, room in ipairs(rooms) do
        if room.intersect(ext_rect) then return false end
    end

    return true
end

-- divide a rectangle into for sub rectangles
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

-- return a random rectangle from a rectangle list
local function getRandomRect(rects)
   return rects[random(#rects)]
end

-- return a random position within a rectangle
local function getRandomPosition(rect)
    local x = rect.x1 + random(0, math.abs(rect.x1 - rect.x2))
    local y = rect.y1 + random(0, math.abs(rect.y1 - rect.y2))
    return x, y
end

function BSPBuilder:build(state)
    print('bsp')

    local map = Map()
    local map_w, map_h = map.size()

    -- add the intial rectangle and divide into subrectangles
    local rect = Rect(1, 1, map_w - 1, map_h - 1)
    local rects = { rect }
    addSubrects(rects, rects[1])

    -- try to add rooms to the map
    local rooms = {}
    for _ = 1, N_TRIES do
        local rect = getRandomRect(rects)
        local candidate = getRandomSubrect(rect)

        -- if candidate room doesn't overlap other room, add to map
        if isPossible(candidate, map, rooms) then
            rooms[#rooms + 1] = candidate
            addSubrects(rects, rect)
        end
    end

    state.map = map
    state.rooms = rooms
end

return BSPBuilder
