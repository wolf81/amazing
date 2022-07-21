local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Map = require(PATH .. '.map')
local Direction = require(PATH .. '.direction')
local BuilderBase = require(PATH .. '.builder_base')
local Util = require(PATH .. '.util')

local shuffle = Util.shuffle
local lrandom = love.math.random

--[[ MAZE BUILDER ]]--

local Builder = BuilderBase.new()

local MAX_ROOMS = 30
local ROOM_SIZE_MIN = 5
local ROOM_SIZE_MAX = 9

local function carve(cx, cy, map)
    local dirs = shuffle({ Direction.N, Direction.S, Direction.E, Direction.W })
    local map_w, map_h = map.size()
    
    local v = map.get(cx, cy)

    for _, dir in ipairs(dirs) do
        local heading = Direction.heading[dir]
        local nx, ny = cx + heading.x, cy + heading.y
        local nv = map.get(nx, ny)

        if nx > 0 and nx < map_w and ny > 0 and ny < map_h and nv == 0 then
            map.set(cx, cy, bit.bor(v, dir))
            map.set(nx, ny, bit.bor(nv, Direction.opposite[dir]))
            carve(nx, ny, map)
        end
    end
end

function Builder.build(state)
    print('maze')

    local map = Map()
    local map_w, map_h = map.size()

    -- create a 50% scaled down map 
    local maze_map = Map(map_w / 2, map_h / 2, 0)
    local maze_map_w, maze_map_h = maze_map.size()

    -- determine random start position
    local start_x, start_y = lrandom(2, maze_map_w - 1), lrandom(2, maze_map_h - 1)

    -- carve the maze
    carve(start_x, start_y, maze_map)

    -- update actual maze map based on the scaled version
    for x, y in maze_map.iter() do
        local mx, my = x * 2, y * 2
        local v = maze_map.get(x, y)

        if mx >= map_w or my >= map_h then goto continue end

        map.set(mx, my, Tile.FLOOR)

        if bit.band(v, Direction.E) == Direction.E then
            map.set(mx + 1, my, Tile.FLOOR)
        end
        if bit.band(v, Direction.W) == Direction.W then
            if mx + 1 > map_w - 2 then goto continue end
            map.set(mx + 1, my, Tile.FLOOR)
        end
        if bit.band(v, Direction.N) == Direction.N then
            map.set(mx, my - 1, Tile.FLOOR)
        end
        if bit.band(v, Direction.S) == Direction.S then
            if my + 1 > map_w - 2 then goto continue end
            map.set(mx, my + 1, Tile.FLOOR)
        end

        ::continue::
    end

    state.map = map
    state.start = { x = start_x * 2, y = start_y * 2 }
end

return Builder
