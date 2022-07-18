local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.common')

local lrandom = love.math.random

local N_SEEDS_MAX = 64

--[[ VORONOI HIVE BUILDER ]]--

local Builder = BuilderBase.new()

function Builder.build(state)
    print('hive')

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

    local size = 0
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
                size = size + 1
            end
        end
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

return Builder
