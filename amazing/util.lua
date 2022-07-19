local PATH = (...):match("(.-)[^%.]+$") 

local msqrt, mceil, mfloor = math.sqrt, math.ceil, math.floor
local mmin, mmax = math.min, math.max
local bband, lrandom = bit.band, love.math.random

--[[ UTILITY FUNCTIONS ]]--

-- generate a Dijkstra map based on a map, start position and blocked function
function dijkstraMap(map, start_x, start_y, blocked_tile)
	local blocked = function(x, y)
		return bband(map.get(x, y), blocked_tile) == blocked_tile
	end

	return Dijkstra.map(map, start_x, start_y, blocked)
end

-- calculate pythgorean distance between to coordinates
function getDistance(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return msqrt((dx ^ 2) + (dy ^ 2)) 
end

-- return true if a random 1-in-n value is equal to 1:
-- * oneIn(1): return true 100% of the time
-- * oneIn(2): return true ~50% of the time
-- * oneIn(3): return true ~33% of the time
-- * oneIn(10): return true ~10% of the time
function oneIn(count)
	return lrandom(count) == 1
end

-- clamp value x to a range of min and max, both inclusive
function clamp(x, min, max)
	return mmin(mmax(x, min), max)
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
	return x < 0 and mceil(x - 0.5) or mfloor(x + 0.5)
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
