io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local amazing = require 'amazing'
local Tile = amazing.Tile

local canvas = nil

local function generate()
    local builder = amazing.builder.random()
    map = builder.build({
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
        end

        love.graphics.setColor(c)
        love.graphics.print(s, x * 12, y * 12)
    end
    love.graphics.setCanvas()
end

function love.load(args)
    generate()
end

function love.draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(canvas)
end

function love.keypressed(key, scancode)
    if key == 'g' then generate() end    
    if key == 'q' then love.event.quit() end
end