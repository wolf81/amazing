local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')

local function decorate(state)
    print('- add room stairs')

    -- add stairs up
    local stair_x, stair_y = state.rooms[1].center()
    state.map.set(stair_x, stair_y, Tile.STAIR_UP)

    -- add stairs down
    stair_x, stair_y = state.rooms[#state.rooms].center()
    state.map.set(stair_x, stair_y, Tile.STAIR_DN)
end

return {
    decorate = decorate,
}