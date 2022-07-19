local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.common')

--[[ BUILDER CHAIN ]]--

local BuilderChain = {}

BuilderChain.new = function(map_builder, decorators, params)
    assert(map_builder ~= nil, 'a map builder must be defined')
    assert(getmetatable(map_builder) == BuilderBase, 'map builder should be of type BuilderBase')

    for _, decorator in ipairs(decorators or {}) do
        assert(getmetatable(decorator) == DecoratorBase, 'decorator should be of type DecoratorBase') 
    end

    local state = {
        map = nil,
        rooms = nil,
        start = nil,
        corridors = nil,
    }

    local build = function()
        map_builder.build(state, params or {})

        for _, decorator in ipairs(decorators or {}) do
            decorator.decorate(state, params or {})
        end

        return state.map
    end

    return {
        build = build,
    }
end

return setmetatable(BuilderChain, {
    __call = function(_, ...) return BuilderChain.new(...) end,
})
