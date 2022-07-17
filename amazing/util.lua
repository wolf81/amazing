local PATH = (...):match("(.-)[^%.]+$") 

local lrandom = love.math.random

-- return true if a random 1-in-n value is equal to 1:
-- * oneIn(1): return true 100% of the time
-- * oneIn(2): return true ~50% of the time
-- * oneIn(3): return true ~33% of the time
-- * oneIn(10): return true ~10% of the time
function oneIn(count)
    return lrandom(count) == 1
end

-- shuffle array
function shuffle(arr)    
    for i = #arr, 2, -1 do
        local j = lrandom(i)
        arr[i], arr[j] = arr[j], arr[i]
    end

    return arr
end

-- round value to nearest integer
function round(x)
    return x < 0 and math.ceil(x - 0.5) or math.floor(x + 0.5)
end

-- make a table read only
function readOnly(table)
   return setmetatable({}, {
      __index = table,
      __newindex = function(table, key, value)
        error("Attempt to modify read-only table")
      end,
      __metatable = false,
   });
end
