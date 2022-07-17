local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Dijkstra = require(PATH .. '.dijkstra')

require(PATH .. '.common')

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