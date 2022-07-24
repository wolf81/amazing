local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local DecoratorBase = require(PATH .. '.decorator_base')
local Util = require(PATH .. '.util')

local oneIn = Util.oneIn

--[[ WALL FIX DECORATOR ]]--

local Decorator = DecoratorBase.new()

function Decorator.decorate(state)
    print('- fix walls')

    local map_w, map_h = state.map.size()

    for y = map_h - 1, 2, -1 do
        for x = 2, map_w - 1 do
            local t1 = state.map.get(x, y)
            local t2 = state.map.get(x + 1, y)
            local t3 = state.map.get(x, y + 1)
            local t4 = state.map.get(x + 1, y + 1)

            if (t1 == Tile.FLOOR and t2 == Tile.WALL and 
                t3 == Tile.WALL and t4 == Tile.FLOOR) then
                if oneIn(2) then
                    state.map.set(x, y, Tile.WALL)
                else
                    state.map.set(x + 1, y + 1, Tile.WALL)
                end
            elseif (t1 == Tile.WALL and t2 == Tile.FLOOR and 
                t3 == Tile.FLOOR and t4 == Tile.WALL) then
                if oneIn(2) then
                    state.map.set(x + 1, y, Tile.WALL)
                else
                    state.map.set(x, y + 1, Tile.WALL)
                end
            end
        end
    end
end

return Decorator
