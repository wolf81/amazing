local PATH = (...):match("(.-)[^%.]+$") 

local DecoratorBase = require(PATH .. '.decorator_base')
local Tile = require(PATH .. '.tile')

require(PATH .. '.common')

local Decorator = DecoratorBase.new()

-- add corridor to map between (x1, y1) and (x2, y2)
local function addCorridor(map, x1, y1, x2, y2)
    local x, y = x1, y1

    while (x ~= x2 or y ~= y2) do
        if x < x2 then
            x = x + 1
        elseif x > x2 then
            x = x - 1
        elseif y < y2 then
            y = y + 1
        elseif y > y2 then
            y = y - 1
        end

        map.set(x, y, Tile.FLOOR)
    end
end

function Decorator.decorate(state)
    print('- nearest corridors')

    local connected = {}
    for i, room in ipairs(state.rooms) do
        local room_dist = {}
        local room_x, room_y = room.center()    

        for j, other in ipairs(state.rooms) do
            if i ~= j and not connected[j] then
                local other_x, other_y = other.center()

                local dist = getDistance(room_x, room_y, other_x, other_y)
                room_dist[#room_dist + 1] = { idx = j, dist = dist }
            end
        end

        if #room_dist > 0 then
            table.sort(room_dist, function(a, b)
                return a.dist < b.dist
            end)

            local other_x, other_y = state.rooms[room_dist[1].idx].center()
            connected[i] = true

            addCorridor(state.map, room_x, room_y, other_x, other_y)
        end
    end
end

return Decorator
