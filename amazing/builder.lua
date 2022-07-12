local PATH = (...):match("(.-)[^%.]+$") 

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')

local function random()
    local builders = { SimpleBuilder, BSPBuilder }
    return builders[love.math.random(#builders)]
end

local function bsp()
    return BSPBuilder
end

local function simple()
    return SimpleBuilder
end

return {
    random = random,
    simple = simple,
    bsp = bsp,
}
