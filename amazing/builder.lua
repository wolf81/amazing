local PATH = (...):match("(.-)[^%.]+$") 

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')

local function random()
    local i = 2 -- love.math.random(2)
    if i == 1 then return SimpleBuilder
    else return BSPBuilder
    end
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
