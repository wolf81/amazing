local PATH = (...):match("(.-)[^%.]+$") 

local DecoratorBase = require(PATH .. '.decorator_base')
local Tile = require(PATH .. '.tile')

local Decorator = DecoratorBase.new()

function Decorator.decorate(state)
    print('- add stairs')

    -- add stairs up
    state.map.set(state.start.x, state.start.y, Tile.STAIR_UP)

    if state.rooms and #state.rooms > 1 then
        -- add stairs down
        local stair_x, stair_y = state.rooms[#state.rooms].center()
        state.map.set(stair_x, stair_y, Tile.STAIR_DN)
    else
        -- create a Dijkstra map which we'll use to calculate tile distances
        local d_map = dijkstraMap(state.map, state.start.x, state.start.y, Tile.WALL)

        -- find tile furthest away from start position to place stairs down
        local stairs = { x = 0, y = 0, dist = 0 }
        for x, y, dist in d_map.iter() do
            if dist > stairs.dist then
                stairs = { x = x, y = y, dist = dist }
            end
        end

        assert(stairs.dist > 0, 'could not place stairs down')

        -- add stairs down
        state.map.set(stairs.x, stairs.y, Tile.STAIR_DN)
    end
end

return Decorator
