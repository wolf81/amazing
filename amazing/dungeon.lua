local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.config')
require(PATH .. '.flags')
require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')

local function tostring(map)
    local s = ''

    local w, h = map.size()
    print(w, h)

    for y = 1, h do
        for x = 1, w do
            local v = map.get(x, y)

            if bit.band(v, Cell.WALL) == Cell.WALL then
                s = s .. '#'
            else
                s = s .. ' '
            end
        end
        s = s .. '\n'
    end

    return s
end

local function computeSeed(seed)
    if seed == nil then
        seed = os.time()
    elseif type(seed) == 'string' then
        local s = 42
        for i = 1, #seed do
            local char = string.sub(seed, i, i)
            s = bit.lshift(s, 5) - s + string.byte(char)
            s = bit.band(s, 0x7FFFFFFF)
        end
        seed = s
    end

    return seed
end

local function applyHorizontalTunnel(map, x1, x2, y)
    for x = x1, x2, x1 < x2 and 1 or -1 do
        map.set(x, y, Cell.FLOOR)
    end
end

local function applyVerticalTunnel(map, y1, y2, x)
    for y = y1, y2, y1 < y2 and 1 or -1 do
        map.set(x, y, Cell.FLOOR)
    end
end

local function applyRoom(map, room)
    for y = room.y1 + 1, room.y2 do
        for x = room.x1 + 1, room.x2 do
            map.set(x, y, Cell.FLOOR)
        end
    end
end

local function init(params)
    local seed = computeSeed(params.seed)
    print('seed', seed)
    love.math.setRandomSeed(seed)

    local map = Map(80, 50, Cell.WALL)
    local w, h = map.size()
    print('len', map.len())

    for x = 1, w do
        map.set(x, 1, Cell.WALL)
        map.set(x, h, Cell.WALL)
    end

    for y = 1, h do
        map.set(1, y, Cell.WALL)
        map.set(w, y, Cell.WALL)
    end

    applyHorizontalTunnel(map, 25, 40, 23)

    -- for i = 1, 400 do
    --     local x = random(w)
    --     local y = random(h)
    --     map.set(x, y, Cell.WALL)
    -- end

    return map
end

--[[ GENERATOR ]]--

return function(params)
    local map = init(params)

    local rooms = {
        Rect(20, 15, 10, 15),
        Rect(35, 15, 10, 15),
    }

    for _, room in ipairs(rooms) do
        applyRoom(map, room)
    end

    -- addRooms(dungeon, params)
    -- addCorridors(dungeon, params)
    
    -- print(tostring(dungeon.map))

    return map
end