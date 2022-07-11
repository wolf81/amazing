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

function round(x)
    return x < 0 and math.ceil(x - 0.5) or math.floor(x + 0.5)
end

function readOnly(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(table, key, value)
                    error("Attempt to modify read-only table")
                  end,
     __metatable = false
   });
end