local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.config')
require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Cell = require(PATH .. '.cell_type')

local function computeSeed(seed)
    if seed == nil then
        seed = os.time()
    elseif type(seed) == 'string' then
        local s = 42
        for i = 1, #seed do
            local char = string.sub(seed, i, i)
            s = bit.lshift(s, 5) - s + string.byte(char)
            s = bit.band(s, 0x7FFFFFFF)
        end
        seed = s
    end

    return seed
end

local function applyHorizontalTunnel(map, x1, x2, y)
    for x = x1, x2, x1 < x2 and 1 or -1 do
        map.set(x, y, Cell.ROOM)
    end
end

local function applyVerticalTunnel(map, y1, y2, x)
    for y = y1, y2, y1 < y2 and 1 or -1 do
        map.set(x, y, Cell.ROOM)
    end
end

local function applyRoom(map, room)
    for y = room.y1 + 1, room.y2 do
        for x = room.x1 + 1, room.x2 do
            map.set(x, y, Cell.ROOM)
        end
    end
end

local function init(params)
    local seed = computeSeed(params.seed)
    print('seed', seed)
    love.math.setRandomSeed(seed)

    return Map(80, 50, Cell.WALL)
end

--[[ GENERATOR ]]--

local MAX_ROOMS = 30
local MIN_SIZE = 6
local MAX_SIZE = 10

return function(params)
    local map = init(params)

    local map_w, map_h = map.size()

    for x = 1, map_w do
        map.set(x, 1, Cell.WALL)
        map.set(x, map_h, Cell.WALL)
    end

    for y = 1, map_h do
        map.set(1, y, Cell.WALL)
        map.set(map_w, y, Cell.WALL)
    end

    local rooms = {}

    for i = 0, MAX_ROOMS do
        local w = random(MIN_SIZE, MAX_SIZE)
        local h = random(MIN_SIZE, MAX_SIZE)
        local x = random(2, map_w - w) - 1
        local y = random(2, map_h - h) - 1

        local room = Rect(x, y, w, h)
        for _, other_room in ipairs(rooms) do
            if room.intersect(other_room) then goto continue end
        end

        applyRoom(map, room)

        if #rooms > 1 then
            local next_x, next_y = room.center()
            local prev_x, prev_y = rooms[#rooms - 1].center()

            if oneIn(2) then
                applyHorizontalTunnel(map, prev_x, next_x, prev_y)
                applyVerticalTunnel(map, prev_y, next_y, next_x)
            else
                applyVerticalTunnel(map, prev_y, next_y, prev_x)
                applyHorizontalTunnel(map, prev_x, next_x, next_y)
            end
        end

        table.insert(rooms, room)

        ::continue::
    end

    local stair_x, stair_y = rooms[#rooms].center()
    map.set(stair_x, stair_y, Cell.STAIR_DN)

    return map
end