local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')
local Dijkstra = require(PATH .. '.dijkstra')

--[[ CELLULAR AUTOMATA ]]--

local CABuilder = {}
CABuilder.__index = BuilderBase

function CABuilder:build(params)
    local map = Map()

    local map_w, map_h = map.size()

    for y = 2, map_h - 1 do
        for x = 2, map_w - 1 do
            if random(1, 100) > 55 then
                map.set(x, y, Tile.FLOOR)
            end
        end
    end

    for _ = 1, 10 do
        local map_copy = map.copy()
        for y = 2, map_h - 2 do
            for x = 2, map_w - 2 do
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

    local x, y = math.floor(map_w / 2), math.floor(map_h / 2)
    local start = nil

    while true do
        local v = map.get(x, y)

        if bit.band(v, Tile.FLOOR) == Tile.FLOOR then
            start = { x = x, y = y }
            map.set(x, y, Tile.STAIR_UP)
            break
        else
            x = x - 1
            if x < 0 then y = y - 1 end
            if y < 0 then error('no empty tiles found') end
        end
    end

    local d_map = Dijkstra.map(map, start.x, start.y, function(x, y)
        return bit.band(map.get(x, y), Tile.WALL) == Tile.WALL
    end)

    local stairs = { x = 0, y = 0, dist = 0 }
    for x, y, dist in d_map.iter() do
        if dist == math.huge then
            map.set(x, y, Tile.WALL)
        else
            if dist > stairs.dist then
                stairs = { x = x, y = y, dist = dist }
            end
        end
    end

    if stairs.dist == 0 then error('could not place stairs down') end
    map.set(stairs.x, stairs.y, Tile.STAIR_DN)

    return map
end

return CABuilder
