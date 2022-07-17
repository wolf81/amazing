local PATH = (...):match("(.-)[^%.]+$") 

--[[ BUILDER BASE CLASS ]]--

local DecoratorBase = {}
DecoratorBase.__index = DecoratorBase

function DecoratorBase.new()
    local decorate = function()
        error('should be implemented by subclasses')
    end

    return setmetatable({
        decorate = decorate,
    }, DecoratorBase)
end

return setmetatable(DecoratorBase, {
    __call = function(_, ...) DecoratorBase.new(...) end,
})
