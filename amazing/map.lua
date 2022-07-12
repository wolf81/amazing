local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')

local M = {}

function new(w, h, v)
    local w = w or 80
    local h = h or 50

    local tiles = {}

    if v == nil or type(v) == 'number' then
        for y = 1, h do
            for x = 1, w do
                table.insert(tiles, v or Tile.WALL)
            end
        end
    elseif type(v) == 'table' then
        local n_items = h * w
        assert(#v == h * w, 'v should contain ' .. n_items ' tiles')
        tiles = v
    end

    local getIndex = function(x, y)
        return (y - 1) * w + x
    end

    local function get(x, y)        
        return tiles[getIndex(x, y)]
    end

    local function set(x, y, v)
        assert(v ~= nil, 'v must be defined')
        tiles[getIndex(x, y)] = v
    end

    local function size()
        return w, h
    end

    local function len()
        return #tiles
    end

    local function iter()
        local x, y = 0, 1

        return function()
            while true do
                x = x + 1

                if x > w then
                    y = y + 1
                    x = 1
                end

                if y > h then break end

                return x, y, tiles[getIndex(x, y)]
            end

            return nil
        end
    end

    local function copy()
        return Map(w, h, tiles)
    end

    return setmetatable({
        get = get,
        set = set,
        len = len,
        size = size,
        iter = iter,
    }, M)
end

return setmetatable(M, {
    __call = function(_, w, h, v) return new(w, h, v) end,
})
