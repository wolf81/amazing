io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local amazing = require 'amazing'

local canvas = nil

local function generate()
    map = amazing.dungeon({
        dungeon_size    = 'medium',
        dungeon_layout  = 'square',
        room_size       = 'small',
        room_layout     = 'dense',
        corridor_layout = 'straight',
    })

    love.graphics.setFont(love.graphics.newFont(12))
    love.window.setMode(1280, 800, { ['highdpi'] = false })

    print('dungeon:')
    for k, v in pairs(map) do
        print('- ' .. k .. ': ' .. tostring(v))
    end
    print()

    canvas = love.graphics.newCanvas()
    love.graphics.setCanvas(canvas)
    for x, y, v in map.iter() do
        local is_wall = v == 16
        local s = is_wall and '#' or '.'
        local c = is_wall and { 0.0, 0.6, 0.0 } or { 1.0, 1.0, 1.0 }   
        love.graphics.setColor(c)
        love.graphics.print(tostring(s), x * 10, y * 10)
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