local PATH = (...):match("(.-)[^%.]+$") 

local DecoratorBase = require(PATH .. '.decorator_base')
local Tile = require(PATH .. '.tile')

local bband = bit.band

local Decorator = DecoratorBase.new()

local function isDoorPossible(map, x, y)
    if (bband(map.get(x, y), Tile.FLOOR) == Tile.FLOOR and
        bband(map.get(x - 1, y), Tile.FLOOR) == Tile.FLOOR and
        bband(map.get(x - 1, y), Tile.FLOOR) == Tile.FLOOR and
        bband(map.get(x, y - 1), Tile.WALL) == Tile.WALL and
        bband(map.get(x, y + 1), Tile.WALL) == Tile.WALL) 
    then
        return true
    end

    if (bband(map.get(x, y), Tile.FLOOR) == Tile.FLOOR and
        bband(map.get(x, y - 1), Tile.FLOOR) == Tile.FLOOR and
        bband(map.get(x, y + 1), Tile.FLOOR) == Tile.FLOOR and
        bband(map.get(x - 1, y), Tile.WALL) == Tile.WALL and
        bband(map.get(x + 1, y), Tile.WALL) == Tile.WALL) 
    then
        return true
    end

    return false
end

function Decorator.decorate(state)
    print('- add doors')

    for _, corridor in ipairs(state.corridors) do
        if #corridor > 3 then
            local x, y = unpack(corridor[1])
            if isDoorPossible(state.map, x, y) then
                state.map.set(x, y, Tile.DOOR)                
            end
        end
    end
end

return Decorator
