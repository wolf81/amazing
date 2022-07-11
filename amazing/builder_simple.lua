local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')

local M = {}

local function applyHorizontalTunnel(map, x1, x2, y)
    for x = x1, x2, x1 < x2 and 1 or -1 do
        map.set(x, y, Tile.ROOM)
    end
end

local function applyVerticalTunnel(map, y1, y2, x)
    for y = y1, y2, y1 < y2 and 1 or -1 do
        map.set(x, y, Tile.ROOM)
    end
end

local function applyRoom(map, room)
    for y = room.y1 + 1, room.y2 do
        for x = room.x1 + 1, room.x2 do
            map.set(x, y, Tile.ROOM)
        end
    end
end

--[[ GENERATOR ]]--

local MAX_ROOMS = 30
local MIN_SIZE = 6
local MAX_SIZE = 10

local function new()
    local build = function(params)
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

        return map
    end

    return setmetatable({ build = build }, M)
end

return setmetatable(M, {
    __call = function(_, ...) return new(...) end,
})
