local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Dijkstra = require(PATH .. '.dijkstra')

local bband, msqrt = bit.band, math.sqrt

function dijkstraMap(map, start_x, start_y, blocked_tile)
    local blocked = function(x, y)
        return bband(map.get(x, y), blocked_tile) == blocked_tile
    end

    return Dijkstra.map(map, start_x, start_y, blocked)
end

function getDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return msqrt((dx ^ 2) + (dy ^ 2)) 
end
