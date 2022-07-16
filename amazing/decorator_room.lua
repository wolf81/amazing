local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')

local function decorate(state)
    print('- add rooms')

    for _, room in ipairs(state.rooms) do
        for x, y in room.iter() do
            state.map.set(x, y, Tile.FLOOR)
        end
    end
end

return {
    decorate = decorate,
}