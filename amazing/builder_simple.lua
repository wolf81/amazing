local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local SimpleBuilder = {}
SimpleBuilder.__index = BuilderBase

--[[ SIMPLE BUILDER ]]--

local MAX_ROOMS = 30
local ROOM_SIZE_MIN = 4
local ROOM_SIZE_MAX = 9

function SimpleBuilder:build(params)
    print('simple')
    
    local map = Map()

    local map_w, map_h = map.size()

    -- add rooms at random positions
    local rooms = {}
    for i = 1, MAX_ROOMS do
        local w = random(ROOM_SIZE_MIN, ROOM_SIZE_MAX) - 1
        local h = random(ROOM_SIZE_MIN, ROOM_SIZE_MAX) - 1
        local x = random(3, map_w - w) - 1
        local y = random(3, map_h - h) - 1

        local room = Rect(x, y, w, h)
        local ok = true

        -- make sure rooms don't overlap
        for _, other_room in ipairs(rooms) do
            local ext_room = room.copy().inset(-1, -1, 1, 1)
            if ext_room.intersect(other_room) then ok = false end
        end

        if ok then
            applyRoom(map, room)

            -- add corridor between newest room and previous room
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
        end

        ::continue::
    end

    -- add stairs up
    local stair_x, stair_y = rooms[1].center()
    map.set(stair_x, stair_y, Tile.STAIR_UP)

    -- add stairs down
    stair_x, stair_y = rooms[#rooms].center()
    map.set(stair_x, stair_y, Tile.STAIR_DN)

    return map
end

-- return setmetatable(M, {
--     __call = function(_, ...) return new(...) end,
-- })
return SimpleBuilder