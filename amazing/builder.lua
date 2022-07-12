local PATH = (...):match("(.-)[^%.]+$") 

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')
local CABuilder = require(PATH .. '.builder_ca')

local function random()
    local builders = { SimpleBuilder, BSPBuilder, CABuilder }
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
