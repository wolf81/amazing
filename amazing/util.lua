local PATH = (...):match("(.-)[^%.]+$") 

local random = love.math.random

function oneIn(count)
    return random(count) == 1
end

function shuffle(list)    
    for i = #list, 2, -1 do
        local j = random(i)
        list[i], list[j] = list[j], list[i]
    end

    return list
end
