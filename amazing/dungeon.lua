local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.config')
require(PATH .. '.flags')
require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')

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

local function init(params)
    local seed = computeSeed(params.seed)
    print('seed', seed)
    love.math.setRandomSeed(seed)

    local map = Map(80, 50, Cell.NOTHING)
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

    for i = 1, 400 do
        local x = random(w)
        local y = random(h)
        map.set(x, y, Cell.WALL)
    end

    return {
        map = map,
    }
end

--[[ GENERATOR ]]--

return function(params)
    local dungeon = init(params)

    for k,v in pairs(dungeon) do
        print(k, v)
    end
    -- addRooms(dungeon, params)
    -- addCorridors(dungeon, params)
    
    -- print(tostring(dungeon.map))

    return dungeon
end