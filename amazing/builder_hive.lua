local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Map = require(PATH .. '.map')
local BuilderBase = require(PATH .. '.builder_base')
local PriorityQueue = require(PATH .. '.pqueue')
local Util = require(PATH .. '.util')
local voronoi = require(PATH .. '.voronoi')

local getDistance = Util.getDistance
local lrandom = love.math.random

--[[ VORONOI HIVE BUILDER ]]--

local Builder = BuilderBase.new()

local function hive(state, params)
    local map = Map()

    local map_w, map_h = map.size()

    local v_membership = voronoi(map, 64)

    for y = 2, map_h - 1 do
        for x = 2, map_w - 1 do
            local neighbors = 0
            local seed = v_membership.get(x, y)
            if v_membership.get(x - 1, y) ~= seed then neighbors = neighbors + 1 end
            if v_membership.get(x + 1, y) ~= seed then neighbors = neighbors + 1 end
            if v_membership.get(x, y - 1) ~= seed then neighbors = neighbors + 1 end
            if v_membership.get(x, y + 1) ~= seed then neighbors = neighbors + 1 end

            if neighbors < 2 then
                map.set(x, y, Tile.FLOOR)
            end
        end
    end

    return map
end

function Builder.build(state, params)
    print('hive')

    local n_floor_tiles, size_min = 0, nil
    local map = hive(state, params)
    local map_w, map_h = map.size()

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

return Builder
