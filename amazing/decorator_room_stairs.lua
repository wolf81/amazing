local PATH = (...):match("(.-)[^%.]+$") 

local DecoratorBase = require(PATH .. '.decorator_base')
local Tile = require(PATH .. '.tile')

local Decorator = DecoratorBase.new()

function Decorator.decorate(state)
    print('- add room stairs')

    assert(state.rooms ~= nil, 'rooms must be defined')

    -- add stairs up
    state.map.set(state.start.x, state.start.y, Tile.STAIR_UP)

    -- add stairs down
    local stair_x, stair_y = state.rooms[#state.rooms].center()
    state.map.set(stair_x, stair_y, Tile.STAIR_DN)
end

return Decorator
