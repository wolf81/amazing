local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Map = require(PATH .. '.map')
local Direction = require(PATH .. '.direction')
local BuilderBase = require(PATH .. '.builder_base')
local Util = require(PATH .. '.util')

local clamp = Util.clamp
local lrandom = love.math.random

--[[ SIMPLE BUILDER ]]--

local Builder = BuilderBase.new()

local INITIAL_DRUNK_LIFE = 600

function Builder.build(state, params)
    print('drunkard')

    local map = Map()

    local map_w, map_h = map.size()
    local start_x, start_y = map_w / 2, map_h / 2
    map.set(start_x, start_y, Tile.FLOOR)

    state.start = { x = start_x, y = start_y }

    local n_floor_tiles_req = map_w * map_h * (params.floor_pct or 0.5)
    local n_diggers_total = 0
    local n_diggers_active = 0

    local n_floor_tiles = 1

    local spawn_mode = params.spawn_mode or 'center' -- center|random

    while n_floor_tiles < n_floor_tiles_req do
        local did_something = false
        local drunk_life = params.drunk_life or 400
        local drunk_x = start_x
        local drunk_y = start_y

        while drunk_life > 0 do
            if bit.band(map.get(drunk_x, drunk_y), Tile.WALL) == Tile.WALL then
                did_something = true
            end

            map.set(drunk_x, drunk_y, Tile.FLOOR)

            local dirs = { Direction.N, Direction.S, Direction.W, Direction.E }
            local dir = dirs[lrandom(#dirs)]
            local heading = Direction.heading[dir]
            drunk_x = clamp(drunk_x + heading.x, 2, map_w - 1)
            drunk_y = clamp(drunk_y + heading.y, 2, map_h - 1)

            drunk_life = drunk_life - 1
        end

        if did_something then
            n_diggers_active = n_diggers_active + 1
        end

        n_diggers_total = n_diggers_total + 1

        n_floor_tiles = 0
        for _, _, tile in map.iter() do
            if bit.band(tile, Tile.FLOOR) == Tile.FLOOR then
                n_floor_tiles = n_floor_tiles + 1
            end
        end

        if spawn_mode == 'random' then
            start_x = lrandom(2, map_w - 1)
            start_y = lrandom(2, map_h - 1)
        end
    end

    state.map = map
end

return Builder
