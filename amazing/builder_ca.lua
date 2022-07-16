local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')
local Dijkstra = require(PATH .. '.dijkstra')

--[[ CELLULAR AUTOMATA BUILDER ]]--

local CABuilder = {}
CABuilder.__index = BuilderBase

function CABuilder:build(state)
    print('ca')

    local map = Map()

    local map_w, map_h = map.size()

    -- add floor tiles to the interior of the map
    for y = 2, map_h - 1 do
        for x = 2, map_w - 1 do
            if random(1, 100) > 55 then
                map.set(x, y, Tile.FLOOR)
            end
        end
    end

    -- perform cellular automata algorithm 10 times of the map tiles
    for _ = 1, 10 do
        local map_copy = map.copy()
        for y = 2, map_h - 1 do
            for x = 2, map_w - 1 do
                local neighbors = 0

                if map.get(x - 1, y) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x + 1, y) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x, y - 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x, y + 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x - 1, y - 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x - 1, y + 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x + 1, y - 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x + 1, y + 1) == Tile.WALL then neighbors = neighbors + 1 end

                if neighbors > 4 or neighbors == 0 then
                    map_copy.set(x, y, Tile.WALL)
                else
                    map_copy.set(x, y, Tile.FLOOR)
                end
            end
        end

        map = map_copy
    end

    -- determine a start position by starting at the center of the map and 
    -- moving left until an empty tile is found
    local x, y = math.floor(map_w / 2), math.floor(map_h / 2)
    local start = nil

    while true do
        local v = map.get(x, y)

        if bit.band(v, Tile.FLOOR) == Tile.FLOOR then
            start = { x = x, y = y }
            break
        else
            x = x - 1
        end
    end

    state.start = start
    state.map = map
end

return CABuilder
