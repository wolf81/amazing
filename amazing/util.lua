local PATH = (...):match("(.-)[^%.]+$") 
local prng = require(PATH .. '.prng')

local random = prng.random

function oneIn(count)
    return random(count) == 1
end

function shuffle(list)    
    for i = #list, 2, -1 do
        local j = random(i)
        list[i], list[j] = list[j], list[i]
    end
end
