local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local SimpleBuilder = {}
SimpleBuilder.__index = BuilderBase

--[[ GENERATOR ]]--

local MAX_ROOMS = 30
local MIN_SIZE = 6
local MAX_SIZE = 10

function SimpleBuilder:build(params)
    local map = Map()

    local map_w, map_h = map.size()

    for x = 1, map_w do
        map.set(x, 1, Tile.WALL)
        map.set(x, map_h, Tile.WALL)
    end

    for y = 1, map_h do
        map.set(1, y, Tile.WALL)
        map.set(map_w, y, Tile.WALL)
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
    map.set(stair_x, stair_y, Tile.STAIR_DN)

    stair_x, stair_y = rooms[1].center()
    map.set(stair_x, stair_y, Tile.STAIR_UP)

    return map
end

-- return setmetatable(M, {
--     __call = function(_, ...) return new(...) end,
-- })
return SimpleBuilder