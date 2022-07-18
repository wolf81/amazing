local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.common')

local mhuge = math.huge

--[[ CULL UNREACHABLE DECORATOR ]]--

local Decorator = DecoratorBase.new()

function Decorator.decorate(state)
    print('- cull unreachable')

    assert(state.start ~= nil, 'a start position is required')

    local d_map = dijkstraMap(state.map, state.start.x, state.start.y, Tile.WALL)
    for x, y, dist in d_map.iter() do
        if dist == mhuge then
            state.map.set(x, y, Tile.WALL)
        end
    end
end

return Decorator
