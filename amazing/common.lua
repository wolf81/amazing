local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Dijkstra = require(PATH .. '.dijkstra')

local band = bit.band

function dijkstraMap(state)
    local blocked = function(x, y)
        return band(state.map.get(x, y), Tile.WALL) == Tile.WALL
    end

    return Dijkstra.map(state.map, state.start.x, state.start.y, blocked)
end
