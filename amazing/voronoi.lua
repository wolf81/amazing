local PATH = (...):match("(.-)[^%.]+$") 

local Map = require(PATH .. '.map')
local PriorityQueue = require(PATH .. '.pqueue')
local Util = require(PATH .. '.util')

local getDistance = Util.getDistance
local lrandom = love.math.random
local blshift = bit.lshift

return function(map, n_seeds_max)
    local map_w, map_h = map.size()

    local seeds = {}
    local n_seeds = 0
    while n_seeds < n_seeds_max do
        local x, y = 1 + lrandom(map_w - 2), 1 + lrandom(map_h - 2)
        local key = blshift(y, 16) + x
        if seeds[key] == nil then -- should use a Set instead
            seeds[key] = { x = x, y = y }
            n_seeds = n_seeds + 1
        end
    end

    local v_membership = Map(map_w, map_h, math.huge)
    for x, y in v_membership.iter() do
        local v_distance = PriorityQueue()
        for seed, pos in pairs(seeds) do
            v_distance:enqueue(seed, getDistance(x, y, pos.x, pos.y))
        end

        v_membership.set(x, y, v_distance:peek())
    end

    return v_membership
end
