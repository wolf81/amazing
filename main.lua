io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local amazing = require 'amazing'
local Tile = amazing.Tile

local PriorityQueue = require 'pqueue'

local canvas = nil
local player = nil
local map = nil
local dx, dy = 0, 0
local step_delay = 0

local function generate()
    local builder = amazing.builder.random()

    map, player = builder.build({
        dungeon_size    = 'medium',
        dungeon_layout  = 'square',
        room_size       = 'small',
        room_layout     = 'dense',
        corridor_layout = 'straight',
    })

    love.graphics.setFont(love.graphics.newFont(14))
    love.window.setMode(1280, 800, { ['highdpi'] = false })

    canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(canvas)
    for x, y, v in map.iter() do
        local s = ' '
        local c = { 1.0, 1.0, 1.0 }

        if bit.band(v, Tile.WALL) ~= 0 then
            s = '#'
            c = { 0.0, 0.6, 0.0 }
        elseif bit.band(v, Tile.STAIR_DN) ~= 0 then
            s = '>'
        elseif bit.band(v, Tile.STAIR_UP) ~= 0 then
            s = '<'
            player = { x = x, y = y }
        end

        love.graphics.setColor(c)
        love.graphics.print(s, x * 12, y * 12)
    end
    love.graphics.setCanvas()

    keys_pressed = {}
end

function love.load(args)
    generate()
end

function love.draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(canvas)

    if player then
        love.graphics.setColor(0.0, 0.0, 0.0)
        love.graphics.rectangle('fill', player.x * 12, player.y * 12, 15, 15)
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.print('@', player.x * 12, player.y * 12)        
    end
end

function isBlocked(x, y)
    return bit.band(map.get(x, y), Tile.WALL) == Tile.WALL
end

local function tryMove(x, y)
    if isBlocked(x, y) then return false end
    
    player.x = x
    player.y = y

    return true
end

function love.update(dt)
    step_delay = step_delay + dt

    dx, dy = 0, 0
    if keys_pressed['left'] then dx = -1 end
    if keys_pressed['right'] then dx = 1 end
    if keys_pressed['up'] then dy = -1 end
    if keys_pressed['down'] then dy = 1 end

    if step_delay > 0.1 then
        step_delay = step_delay - 0.1

        if player then
            tryMove(player.x + dx, player.y + dy)

            if dx ~= 0 or dy ~= 0 then
                dijkstra()
            end
        end
    end
end

function love.keypressed(key, scancode)
    if key == 'g' then generate() end    
    if key == 'q' then love.event.quit() end

    keys_pressed[key] = true
end

function love.keyreleased(key, scancode)
    keys_pressed[key] = nil
end


local Map = amazing.Map



function getKeysSortedByValue(tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)

  return keys
end



    function getNeighbors(x, y)
        return { 
            { x - 1, y },
            { x + 1, y },
            { x, y - 1 },
            { x, y + 1 },
        }
    end

    local getKey = function(x, y) return bit.lshift(y, 16) + x end

function dijkstra()
    print('update dijkstra map')

    local d_map = Map(map_w, map_h, math.huge)
    local unvisited = PriorityQueue()

    local enc = bit.lshift(player.y, 16) + player.x
    local px = bit.band(enc, 0xFF)
    local py = bit.rshift(enc, 16)
    print(player.x, player.y, '->', px, py)

    for x, y, _ in map.iter() do
        local dist = (x == player.x and y == player.y) and 0 or math.huge
        d_map.set(x, y, dist)
        unvisited:enqueue(getKey(x, y), dist)
    end

    while not unvisited:empty() do
        local item, dist = unvisited:dequeue()
        local x = bit.band(item, 0xFF)
        local y = bit.rshift(item, 16)

        for _, neighbor in ipairs(getNeighbors(x, y)) do
            local n_x, n_y = unpack(neighbor)
            local n_key = getKey(n_x, n_y)
            if not unvisited:contains(n_key) then goto continue end

            local n_dist = math.min(d_map.get(n_x, n_y), dist + 1)
            unvisited:update(getKey(n_x, n_y), n_dist)

            ::continue::
        end
        unvisited:remove(item)

        print('SET', x, y, dist)

        d_map.set(x, y, dist)
    end

    print('DONE')


    -- assign to every node a tentative distance value: 
    -- set it to zero for our initial node and to infinity for all other nodes
    -- d_map.set(player.x, player.y, 0)
    -- unvisited[getKey(player.x, player.y)] = nil


    -- 
    -- compare the newly calculated tentative distance to the one currently 
    -- assigned to the neighbor and assign it the smaller one
    -- 
    -- for example, if the current node A is marked with a distance of 6, and 
    -- the edge connecting it with a neighbor B has length 2, then the distance 
    -- to B through A will be 6 + 2 = 8
    -- 
    -- if B was previously marked with a distance greater than 8 then change it 
    -- to 8 - otherwise, the current value will be kept

    local map_w, map_h = d_map.size()
    local s = ''
    for y = 1, map_h do
        for x = 1, map_w do
            local v = d_map.get(x,y)
            v = v < 16 and string.format('%X', v) or 'F'
            s = s .. (v == math.huge and '·' or v)
        end
        s = s .. '\n'
    end

    print(s)
end

--[[
-- test graph: if G[u][v] == 0, there is no edge between u and v
G = {
    -- 1   2   3   4   5   6
    {  0,  0, 13,  0, 16,  8 }, -- 1
    {  0,  0,  0,  6,  0, 10 }, -- 2
    { 13,  0,  0, 14,  0, 11 }, -- 3
    {  0,  6, 14,  0,  5, 17 }, -- 4
    { 16,  0,  0,  5,  0,  7 }, -- 5
    {  8, 10, 11, 17,  7,  0 }  -- 6
}

local INF = 1/0 -- not really needed

local extract_min = function(q, d)
    local m = INF
    local i = 0
    for k, v in pairs(q) do
        if d[v] < m then
            m = d[v]
            i = k
        end
    end
    q[i] = nil -- remove i
    return i
end

function dijkstra (graph, start)
    local n = table.getn(graph) -- #vertices
    local d = {}
    local previous = {}
    for v = 1, n do d[v] = INF end
    d[start] = 0
    local S = {}
    local Q = {}
    for v = 1, n do Q[v] = v end -- fill Q
    local nQ = n -- # elements in Q
    while nQ > 0 do
        local u = extract_min(Q, d)
        nQ = nQ - 1
        table.insert(S, u)
        for v = 1, n do
            if G[u][v] > 0 -- edge between u and v?
                    and d[v] > d[u] + G[u][v] then -- relax
                d[v] = d[u] + G[u][v]
                previous[v] = u
            end
        end
    end
    return d, previous
end

function path (p, start)
    local i = start
    local t = { i }
    while p[i] do
        table.insert(t, 1, p[i])
        i = p[i]
    end
    return t
end

d,p = dijkstra(G, 1)
table.foreach(d, print)
print()
table.foreach(p, print)
print()
for i = 1, table.getn(G) do print(i, d[i], table.concat(path(p, i), ' -> ')) end
--]]
