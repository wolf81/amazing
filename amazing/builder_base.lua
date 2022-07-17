local PATH = (...):match("(.-)[^%.]+$") 

--[[ BUILDER BASE CLASS ]]--

local BuilderBase = {}
BuilderBase.__index = BuilderBase

function BuilderBase.new()
    local build = function()
        error('should be implemented by subclasses')
    end

    return setmetatable({
        build = build,
    }, BuilderBase)
end

return setmetatable(BuilderBase, {
    __call = function(_, ...) BuilderBase.new(...) end,
})
