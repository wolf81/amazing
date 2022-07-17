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
local ROOM_SIZE_MIN = 5
local ROOM_SIZE_MAX = 9

function SimpleBuilder:build(state)
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
            table.insert(rooms, room)
        end

        ::continue::
    end

    state.map = map
    state.rooms = rooms

    local start_x, start_y = rooms[1].center()
    state.start = { x = start_x, y = start_y }
end

return SimpleBuilder
