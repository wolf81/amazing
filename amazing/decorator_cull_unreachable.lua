local PATH = (...):match("(.-)[^%.]+$") 

local DecoratorBase = require(PATH .. '.decorator_base')
local Tile = require(PATH .. '.tile')

require(PATH .. '.common')

local Decorator = DecoratorBase.new()

function Decorator.decorate(state)
    print('- cull unreachable')

    assert(state.start ~= nil, 'a start position is required')

    local d_map = dijkstraMap(state.map, state.start.x, state.start.y, Tile.WALL)
    for x, y, dist in d_map.iter() do
        if dist == math.huge then
            state.map.set(x, y, Tile.WALL)
        end
    end
end

return Decorator
