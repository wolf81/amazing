local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Map = require(PATH .. '.map')
local BuilderBase = require(PATH .. '.builder_base')
local PriorityQueue = require(PATH .. '.pqueue')
local Util = require(PATH .. '.util')

local getDistance = Util.getDistance
local lrandom = love.math.random

--[[ VORONOI HIVE BUILDER ]]--

local Builder = BuilderBase.new()

local N_SEEDS_MAX = 64

local function hive(state, params)
    local map = Map()

    local map_w, map_h = map.size()

    local seeds = {}
    local n_seeds = 0
    while n_seeds < N_SEEDS_MAX do
        local x, y = 1 + lrandom(map_w - 2), 1 + lrandom(map_h - 2)
        local key = bit.lshift(y, 16) + x
        if seeds[key] == nil then -- should use a Set instead
            seeds[key] = { x = x, y = y }
            n_seeds = n_seeds + 1
        end
    end

    local v_membership = Map(map_w, map_h, math.huge)
    for x, y in v_membership.iter() do
        local v_distance = PriorityQueue()
        for seed, pos in pairs(seeds) do
            local distance = getDistance(x, y, pos.x, pos.y)
            v_distance:enqueue(seed, distance)
        end

        v_membership.set(x, y, v_distance:peek())
    end

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
