local Map = {}

function new(w, h, v)
    local items = {}

    local getIndex = function(x, y)
        return (y - 1) * w + x
    end

    for y = 1, h do
        for x = 1, w do
            table.insert(items, v or 0)
        end
    end

    local function get(x, y)        
        return items[getIndex(x, y)]
    end

    local function set(x, y, v)
        assert(v ~= nil, 'v must be defined')
        items[getIndex(x, y)] = v
    end

    local function size()
        return w, h
    end

    local function len()
        return #items
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

                return x, y, items[getIndex(x, y)]
            end

            return nil
        end
    end

    return setmetatable({
        get = get,
        set = set,
        len = len,
        size = size,
        iter = iter,
    }, Map)
end

return setmetatable(Map, {
    __call = function(_, w, h, v) return new(w, h, v) end,
})