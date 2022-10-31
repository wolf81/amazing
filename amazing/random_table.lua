local lrandom = love.math.random

local RandomTable = {}
RandomTable.__index = RandomTable

local function sort(entries)
    table.sort(entries, function(item1, item2)
        return item1.weight < item2.weight
    end)
end

-- a random table contains a list of ids and weights, e.g.:
--  { [1]        = 5, [2]          = 15, ... } 
--    -or-
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

        if weight > 0 then
            self.entries[#self.entries + 1] = { id = id, weight = weight }
            self.total = self.total + weight
        end
    end

    sort(self.entries)

    local add = function(id, weight)
        for _, entry in ipairs(self.entries) do
            if entry.id == id then
                error('already added: ' .. id)
            end
        end

        self.entries[#self.entries + 1] = { id = id, weight = weight }
        self.total = self.total + weight

        sort(self.entries)
    end

    local remove = function(id)
        for idx, entry in ipairs(self.entries) do
            if entry.id == id then
                self.total = self.total - entry.weight
                table.remove(self.entries, idx)
            end
        end
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
    { __call = function(_, ...) return new(...) end }
)
