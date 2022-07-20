local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.common')

--[[ BUILDER CHAIN ]]--

local BuilderChain = {}

BuilderChain.new = function(map_builder, decorators, params)
    assert(map_builder ~= nil, 'a map builder must be defined')
    assert(getmetatable(map_builder) == BuilderBase, 'map builder should be of type BuilderBase')

    local params = params or {}
    
    for _, decorator in ipairs(decorators or {}) do
        assert(getmetatable(decorator) == DecoratorBase, 'decorator should be of type DecoratorBase') 
    end

    local state = {
        map         = nil, -- a 2D grid containing various tiles
        rooms       = nil, -- a list of rooms, if appropriate for map type
        corridors   = nil, -- a list of corridors, if appropriate for map type
        start       = nil, -- a start position for a player
        spawns      = {},  -- a list of spawns if a spawn table was provided
    }

    local build = function()
        map_builder.build(state, params or {})

        for _, decorator in ipairs(decorators or {}) do
            decorator.decorate(state, params or {})
        end

        if params.random_table ~= nil then
            state.spawns = Spawner(params.random_table).spawn(state)
        end

        return state.map, state.spawns
    end

    return {
        build = build,
    }
end

return setmetatable(BuilderChain, {
    __call = function(_, ...) return BuilderChain.new(...) end,
})
