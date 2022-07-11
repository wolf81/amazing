local PATH = (...):match("(.-)[^%.]+$") 

local Simple = require(PATH .. '.builder_simple')
local BSP = require(PATH .. '.builder_bsp')

local function init(params)
    return Map(80, 50, Cell.WALL)
end

local function random()
    local i = love.math.random(2)
    if i == 1 then return Simple()
    else return BSP()
    end
end

return {
    random = random,
}
