local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Dijkstra = require(PATH .. '.dijkstra')

local function dijkstraMap(state)
    local blocked = function(x, y)
        return bit.band(state.map.get(x, y), Tile.WALL) == Tile.WALL
    end

    return Dijkstra.map(state.map, state.start.x, state.start.y, blocked)
end

local function decorate(state)
    print('- add area stairs')

    -- add stairs up
    state.map.set(state.start.x, state.start.y, Tile.STAIR_UP)

    -- create a Dijkstra map which we'll use to calculate tile distances
    local d_map = dijkstraMap(state)

    -- find tile furthest away from start position to place stairs down
    local stairs = { x = 0, y = 0, dist = 0 }
    for x, y, dist in d_map.iter() do
        if dist > stairs.dist then
            stairs = { x = x, y = y, dist = dist }
        end
    end

    assert(stairs.dist > 0, 'could not place stairs down')

    -- add stairs down
    state.map.set(stairs.x, stairs.y, Tile.STAIR_DN)    
end

return {
    decorate = decorate,
}