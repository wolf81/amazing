io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local amazing = require 'amazing'
local Tile = amazing.Tile

local canvas = nil
local player = nil
local map = nil
local dx, dy = 0, 0
local step_delay = 0

local random_tbl = amazing.RandomTable({ 
    ['g'] = 70, -- goblin
    ['o'] = 30, -- orc
    ['b'] = 15, -- bandit
    ['p'] = 5,  -- ogre
    ['$'] = 3,  -- gold
    ['?'] = 2,  -- scroll
    [']'] = 3,  -- armor
    ['/'] = 3,  -- dagger
    ['['] = 1,  -- shield
})

local function generate()
    local builder = amazing.builder.random(random_tbl)

    map, spawns = builder.build({
        dungeon_size    = 'medium',
        dungeon_layout  = 'square',
        room_size       = 'small',
        room_layout     = 'dense',
        corridor_layout = 'straight',
    })

    love.graphics.setFont(love.graphics.newFont(14))
    love.window.setTitle('Amazing')
    love.window.setMode(1280, 800, { ['highdpi'] = false })

    canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(canvas)
    for x, y, v in map.iter() do
        local s = ' '
        local c = { 1.0, 1.0, 1.0 }

        if bit.band(v, Tile.WALL) ~= 0 then
            s = '#'
            c = { 0.0, 0.6, 0.0 }
        elseif bit.band(v, Tile.DOOR) ~= 0 then
            s = '+'
            c = { 1.0, 0.0, 1.0 }
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

    print()
end

function love.load(args)
    love.math.setRandomSeed(1)
    generate()
end

function love.draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(canvas)

    for _, spawn in ipairs(spawns) do
        love.graphics.setColor(0.0, 0.0, 0.0)
        love.graphics.rectangle('fill', spawn.x * 12, spawn.y * 12, 15, 15)
        love.graphics.setColor(0.0, 0.6, 0.6)
        love.graphics.print(spawn.id, spawn.x * 12, spawn.y * 12)                        
    end

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

    for idx, spawn in ipairs(spawns) do
        if spawn.x == player.x and spawn.y == player.y then
            table.remove(spawns, idx)
        end
    end

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
        end
    end

    if not player then return end

    local tile = map.get(player.x, player.y)
    if bit.band(tile, Tile.STAIR_DN) == Tile.STAIR_DN then
        generate()
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
