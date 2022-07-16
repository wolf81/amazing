local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local Tile = require(PATH .. '.tile')

function getDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt((dx ^ 2) + (dy ^ 2)) 
end

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

local function decorate(state)
    print('- add rooms')

    for _, room in ipairs(state.rooms) do
        if oneIn(4) then 
            circle(state, room) 
        else 
            rectangle(state, room) 
        end
    end
end

return {
    decorate = decorate,
}