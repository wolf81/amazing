local PATH = (...):match("(.-)[^%.]+$") 

local voronoi = require(PATH .. '.voronoi')
local lrandom = love.math.random

local Spawner = {}

local BLOCKED_MASK = bit.bor(Tile.STAIR_DN, Tile.STAIR_UP, Tile.WALL, Tile.DOOR)

local function spawnRooms(state, random_table)
    local spawns = {}

    for _, room in ipairs(state.rooms) do
        local spawn_id = random_table.roll()

        local x = lrandom(room.x1, room.x2)
        local y = lrandom(room.y1, room.y2)

        local tile = state.map.get(x, y)
        if bit.band(tile, BLOCKED_MASK) ~= 0 then
            goto continue
        end

        spawns[#spawns + 1] = { x = x, y = y, id = spawn_id }

        ::continue::
    end

    return spawns
end

local function new(random_table)
    assert(random_table ~= nil, 'a random table is required')
    assert(getmetatable(random_table) == RandomTable, 
        'a random table should be of type RandomTable'
    )

    local spawn = function(state)
        if state.rooms then
            return spawnRooms(state, random_table)
        end

        return {}
    end

    return setmetatable({
        spawn = spawn,
    }, Spawner)
end

return setmetatable(Spawner, { 
    __call = function(_, ...) return new(...) end 
})
