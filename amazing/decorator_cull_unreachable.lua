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
    print('- cull unreachable')

    assert(state.start ~= nil, 'a start position is required')

    local d_map = dijkstraMap(state)
    for x, y, dist in d_map.iter() do
        if dist == math.huge then
            state.map.set(x, y, Tile.WALL)
        end
    end
end

return {
    decorate = decorate,
}