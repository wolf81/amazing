local PATH = (...):match("(.-)[^%.]+$") 

local Tile = require(PATH .. '.tile')
local Map = require(PATH .. '.map')
local BuilderBase = require(PATH .. '.builder_base')

local lrandom = love.math.random

--[[ PREFAB BUILDER ]]--

local Builder = BuilderBase.new()

local char_to_tile = {
    ['#'] = Tile.WALL,
    [' '] = Tile.FLOOR,
    ['<'] = Tile.STAIR_UP,
    ['>'] = Tile.STAIR_DN,
    ['+'] = Tile.DOOR,
    ['@'] = Tile.FLOOR,
}

function Builder.build(state, params)
    print('prefab')

    local map_w = #string.match(params.map, "(.-)\n")
    local prefab, map_h = string.gsub(params.map, '\n', '')
    local map = Map(map_w, map_h, Tile.WALL)

    local start = nil

    for y = 1, map_h do
        for x = 1, map_w do
            local i = (y - 1) * map_w + x
            local c = string.sub(prefab, i, i)        
            map.set(x, y, char_to_tile[c])

            if c == '@' then
                start = { x = x, y = y }
            end
        end
    end

    if not start then
        -- determine a start position by starting at the center of the map and 
        -- moving left until an empty tile is found
        local x, y = math.floor(map_w / 2), math.floor(map_h / 2)
        local start = nil

        while true do
            local v = map.get(x, y)

            if bit.band(v, Tile.FLOOR) == Tile.FLOOR then
                start = { x = x, y = y }
                break
            else
                x = x - 1
            end
        end
    end

    state.start = start
    state.map = map
end

return Builder
