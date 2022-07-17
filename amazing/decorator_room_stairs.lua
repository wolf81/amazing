local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')

local function decorate(state)
    print('- add room stairs')

    assert(state.rooms ~= nil, 'rooms must be defined')

    -- add stairs up
    state.map.set(state.start.x, state.start.y, Tile.STAIR_UP)

    -- add stairs down
    local stair_x, stair_y = state.rooms[#state.rooms].center()
    state.map.set(stair_x, stair_y, Tile.STAIR_DN)
end

return {
    decorate = decorate,
}