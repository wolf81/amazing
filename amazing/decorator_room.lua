local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')
require(PATH .. '.common')

local DecoratorBase = require(PATH .. '.decorator_base')
local Tile = require(PATH .. '.tile')

local Decorator = DecoratorBase.new()

local function rectangle(state, room)
    for x, y in room.iter() do
        state.map.set(x, y, Tile.FLOOR)
    end
end

local function circle(state, room)
    local center_x, center_y = room.center()
    local r = math.floor(math.min(
        math.abs(room.x1 - room.x2), 
        math.abs(room.y1 - room.y2)
    ) / 2)

    for x, y in room.iter() do
        if getDistance(center_x, center_y, x, y) <= r then
            state.map.set(x, y, Tile.FLOOR)
        end
    end
end

function Decorator.decorate(state)
    print('- add rooms')

    for _, room in ipairs(state.rooms) do
        if oneIn(4) then 
            circle(state, room) 
        else 
            rectangle(state, room) 
        end
    end
end

return Decorator
