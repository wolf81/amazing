local random = love and love.math.random or math.random
local setRandomSeed = love and love.math.setRandomSeed or math.randomseed

return {
    random = random,
    setRandomSeed = setRandomSeed,
}