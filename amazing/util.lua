local PATH = (...):match("(.-)[^%.]+$") 
local prng = require(PATH .. '.prng')

local random = prng.random

function oneIn(count)
    return random(count) == 1
end

