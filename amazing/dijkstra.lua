local PATH = (...):match("(.-)[^%.]+$") 

local PriorityQueue = require(PATH .. '.pqueue')
local Map = require(PATH .. '.map')
local Tile = require(PATH .. '.tile')

--[[ DIJKSTRA MAP ]] --

local function getNeighbors(x, y)
    return { 
        { x - 1, y },
        { x + 1, y },
        { x, y - 1 },
        { x, y + 1 },
    }
end

local function getKey(x, y)
    return bit.lshift(y, 16) + x
end

local function dijkstra_map(map, x, y, blocked)
    local map_w, map_h = map.size()
    local start = { x = x, y = y }    
    local d_map = Map(map_w, map_h, math.huge)
    local unvisited = PriorityQueue()

    for x, y, _ in map.iter() do
        if blocked(x, y) then
            d_map.set(x, y, -1)
        else
            d_map.set(x, y, math.huge)
            unvisited:enqueue(getKey(x, y), math.huge)
        end
    end

    d_map.set(start.x, start.y, 0)
    unvisited:update(getKey(start.x, start.y), 0)

    while not unvisited:empty() do
        local item, dist = unvisited:dequeue()
        local x = bit.band(item, 0xFF)
        local y = bit.rshift(item, 16)

        for _, neighbor in ipairs(getNeighbors(x, y)) do
            local n_x, n_y = unpack(neighbor)
            local n_key = getKey(n_x, n_y)
            if not unvisited:contains(n_key) then goto continue end

            local n_v = d_map.get(n_x, n_y) 

            local n_dist = math.min(d_map.get(n_x, n_y), dist + 1)
            unvisited:update(getKey(n_x, n_y), n_dist)

            ::continue::
        end
        unvisited:remove(item)

        d_map.set(x, y, dist)
    end

    --[[
    local map_w, map_h = d_map.size()
    local s = ''
    for y = 1, map_h do
        for x = 1, map_w do
            local v = d_map.get(x,y)
            if v == -1 then 
                s = s .. ' ' 
            else 
                v = v < 16 and string.format('%X', v) or 'F'
                s = s .. (v == math.huge and '·' or v)
            end
        end
        s = s .. '\n'
    end
    print(s)
    --]]

    return d_map
end

return {
    map = dijkstra_map
}