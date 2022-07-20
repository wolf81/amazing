local lrandom = love.math.random

local RandomTable = {}

-- a random table contains a list of ids and weights, e.g.:
--  { [1]        = 5, [2]          = 15, ... } 
-- ...or...
--  { ['zombie'] = 5, ['skeleton'] = 15, ... }
local function new(tbl)
    local tbl = tbl or {}
    assert(type(tbl) == 'table', 'invalid argument type, table required')

    local self = {
        entries = {},
        total = 0,
    }

    for id, weight in pairs(tbl or {}) do
        assert(type(weight) == 'number', 'the weight value should be a number')

        self.entries[#self.entries + 1] = { id = id, weight = weight }
        self.total = self.total + weight
    end

    local add = function(id, weight)
        -- body
    end

    local remove = function(id)
        -- body
    end

    local roll = function()
        if self.total == 0 then return nil end

        local roll = lrandom(self.total)

        for _, entry in ipairs(self.entries) do
            if roll <= entry.weight then return entry.id end

            roll = roll - entry.weight
        end

        return nil
    end

    local total = function()
        return self.total
    end

    return setmetatable({
        add = add,
        remove = remove,
        roll = roll,
        total = total,
    }, RandomTable)
end

return setmetatable(RandomTable, 
    { __call = function(_, ...) return new(...) end}
)
