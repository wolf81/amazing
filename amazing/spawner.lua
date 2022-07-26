local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')

local voronoi = require(PATH .. '.voronoi')
local lrandom = love.math.random

local Spawner = {}

local BLOCKED_MASK = bit.bor(Tile.STAIR_DN, Tile.STAIR_UP, Tile.WALL, Tile.DOOR)

local function spawnRegions(regions, spawn_table)
    local spawns = {}

    for _, region in pairs(regions) do
        local tile = region[lrandom(#region)]

        local spawn_id = spawn_table.roll()
        spawns[#spawns + 1] = { x = tile.x, y = tile.y, id = spawn_id }
    end

    return spawns
end

local function spawnRooms(state, spawn_table)
    local regions = {}

    for id, room in ipairs(state.rooms) do
        local x = lrandom(room.x1, room.x2)
        local y = lrandom(room.y1, room.y2)

        local tile = state.map.get(x, y)
        if bit.band(tile, BLOCKED_MASK) ~= 0 then
            goto continue
        end

        local region = regions[id] or {}
        region[#region + 1] = { x = x, y = y }
        regions[id] = region

        ::continue::
    end

    return spawnRegions(regions, spawn_table)
end

local function spawnAreas(state, spawn_table)
    local regions = {}

    local v_membership = voronoi(state.map, 48)
    local map_w, map_h = v_membership.size()
    for x, y, _ in v_membership.iter() do
        local tile = state.map.get(x, y)
        if bit.band(tile, BLOCKED_MASK) ~= 0 then goto continue end

        local region_key = v_membership.get(x, y)
        local region = regions[region_key] or {}
        region[#region + 1] = { x = x, y = y }
        regions[region_key] = region

        ::continue::
    end

    return spawnRegions(regions, spawn_table)
end

local function spawnCoords(state, spawn_table)
    local spawns = {}

    for _, spawn in ipairs(state.spawns) do
        spawns[#spawns + 1] = { 
            x = spawn.x, y = spawn.y, id = spawn_table.roll() 
        }
    end

    return spawns
end

local function new(spawn_table)
    assert(spawn_table ~= nil, 'a spawn table is required')
    -- assert(getmetatable(spawn_table) == RandomTable, 
    --     'a random table should be of type RandomTable'
    -- )

    local spawn = function(state)
        if #state.spawns > 0 then
            return spawnCoords(state, spawn_table)
        elseif state.rooms then
            return spawnRooms(state, spawn_table)
        else
            return spawnAreas(state, spawn_table)
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
