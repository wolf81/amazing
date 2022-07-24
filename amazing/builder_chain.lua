local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')
local DecoratorBase = require(PATH .. '.decorator_base')
local Spawner = require(PATH .. '.spawner')

--[[ BUILDER CHAIN ]]--

local BuilderChain = {}

local function generateMap(map_builder, decorators, params)
    local state = {
        map         = nil, -- a 2D grid containing various tiles
        rooms       = nil, -- a list of rooms, if appropriate for map type
        corridors   = nil, -- a list of corridors, if appropriate for map type
        start       = nil, -- a start position for a player
        spawns      = {},  -- a list of spawns if a spawn table was provided
    }

    map_builder.build(state, params or {})

    for _, decorator in ipairs(decorators or {}) do
        decorator.decorate(state, params or {})
    end

    local map_w, map_h = state.map.size()
    local size = map_w * map_h
    for _, _, tile in state.map.iter() do
        if bit.band(tile, Tile.WALL) == Tile.WALL then
            size = size - 1
        end
    end

    return state, size / (map_w * map_h)
end

BuilderChain.new = function(map_builder, decorators, params)
    assert(map_builder ~= nil, 'a map builder must be defined')
    assert(getmetatable(map_builder) == BuilderBase, 'map builder should be of type BuilderBase')

    local params = params or {}
    
    for _, decorator in ipairs(decorators or {}) do
        assert(getmetatable(decorator) == DecoratorBase, 'decorator should be of type DecoratorBase') 
    end

    local build = function()
        local state, cover = nil, nil

        -- ensure any map covers 25% of the area
        repeat 
            state, cover = generateMap(map_builder, decorators, params)
        until cover >= 0.25

        -- add spawns based on spawn table
        if params.spawn_table ~= nil then
            state.spawns = Spawner(params.spawn_table).spawn(state)
        end

        return state.map, state.start, state.spawns
    end

    return {
        build = build,
    }
end

return setmetatable(BuilderChain, {
    __call = function(_, ...) return BuilderChain.new(...) end,
})
