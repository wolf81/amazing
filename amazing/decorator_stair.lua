local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local DecoratorBase = require(PATH .. '.decorator_base')
local Util = require(PATH .. '.util')

local dijkstraMap, getDistance = Util.dijkstraMap, Util.getDistance

--[[ STAIRS DECORATOR ]]--

local Decorator = DecoratorBase.new()

function Decorator.decorate(state)
    print('- add stairs')

    -- add stairs up
    state.map.set(state.start.x, state.start.y, Tile.STAIR_UP)

    -- determine stair down position
    local stair_x, stair_y = nil, nil
    if state.rooms and #state.rooms > 1 then
        local room_dist = {}

        for _, room in ipairs(state.rooms) do
            local cx, cy = room.center()
            local dist = getDistance(state.start.x, state.start.y, cx, cy)
            room_dist[#room_dist + 1] = { room = room, dist = dist }
        end

        table.sort(room_dist, function(a, b) return a.dist > b.dist end)

        stair_x, stair_y = room_dist[1].room.center()
    else
        -- create a Dijkstra map which we'll use to calculate tile distances
        local d_map = dijkstraMap(state.map, state.start.x, state.start.y, Tile.WALL)

        -- find tile furthest away from start position to place stairs down
        local stair_dn = { x = 0, y = 0, dist = 0 }
        for x, y, dist in d_map.iter() do
            if dist > stair_dn.dist then
                stair_dn = { x = x, y = y, dist = dist }
            end
        end

        stair_x, stair_y = stair_dn.x, stair_dn.y
    end

    assert(stair_x ~= nil and stair_y ~= nil, 'could not place stair down')

    -- add stairs down
    state.map.set(stair_x, stair_y, Tile.STAIR_DN)
end

return Decorator
