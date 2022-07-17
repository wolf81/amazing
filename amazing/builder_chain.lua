local BuilderChain = {}

BuilderChain.new = function(map_builder, decorators)
    assert(map_builder ~= nil, 'a map builder must be defined')

    local state = {
        map = nil,
        rooms = nil,
        start = nil,
        corridors = nil,
    }

    local build = function()
        print('build map')

        -- TODO: should use simple '.' API like decorators instead of ':'
        map_builder.build(state)

        for _, decorator in ipairs(decorators or {}) do
            decorator.decorate(state)
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
