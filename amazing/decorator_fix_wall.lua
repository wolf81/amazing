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

    -- first iteration: replace floor for wall
    for y = map_h - 1, 2, -1 do
        for x = map_w - 1, 2, -1 do
            local t1 = state.map.get(x, y)
            local t2 = state.map.get(x + 1, y)
            local t3 = state.map.get(x, y + 1)
            local t4 = state.map.get(x + 1, y + 1)

            if (bit.band(t1, Tile.FLOOR) == Tile.FLOOR and 
                bit.band(t2, Tile.WALL) == Tile.WALL and 
                bit.band(t3, Tile.WALL) == Tile.WALL and 
                bit.band(t4, Tile.FLOOR) == Tile.FLOOR) then
                if oneIn(2) then
                    state.map.set(x, y, Tile.WALL)
                else
                    state.map.set(x + 1, y + 1, Tile.WALL)
                end
            elseif (bit.band(t1, Tile.WALL) == Tile.WALL and 
                bit.band(t2, Tile.FLOOR) == Tile.FLOOR and 
                bit.band(t3, Tile.FLOOR) == Tile.FLOOR and
                bit.band(t4, Tile.WALL) == Tile.WALL) then
                if oneIn(2) then
                    state.map.set(x + 1, y, Tile.WALL)
                else
                    state.map.set(x, y + 1, Tile.WALL)
                end
            end
        end
    end

    -- second iteration: replace wall for floor
    for y = map_h - 1, 2, -1 do
        for x = map_w - 1, 2, -1 do
            local t1 = state.map.get(x, y)
            local t2 = state.map.get(x + 1, y)
            local t3 = state.map.get(x, y + 1)
            local t4 = state.map.get(x + 1, y + 1)

            if (bit.band(t1, Tile.FLOOR) == Tile.FLOOR and 
                bit.band(t2, Tile.WALL) == Tile.WALL and 
                bit.band(t3, Tile.WALL) == Tile.WALL and 
                bit.band(t4, Tile.FLOOR) == Tile.FLOOR) then
                if oneIn(2) then
                    state.map.set(x + 1, y, Tile.FLOOR)
                else
                    state.map.set(x, y + 1, Tile.FLOOR)
                end
            elseif (bit.band(t1, Tile.WALL) == Tile.WALL and 
                bit.band(t2, Tile.FLOOR) == Tile.FLOOR and 
                bit.band(t3, Tile.FLOOR) == Tile.FLOOR and
                bit.band(t4, Tile.WALL) == Tile.WALL) then
                if oneIn(2) then
                    state.map.set(x, y, Tile.FLOOR)
                else
                    state.map.set(x + 1, y + 1, Tile.FLOOR)
                end
            end
        end
    end    
end

return Decorator
