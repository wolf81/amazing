io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local amazing = require 'amazing'

local function generate()
    local dungeon = amazing.dungeon({
        dungeon_size = 'medium',
        dungeon_layout = 'square',
        room_size = 'small',
        room_layout = 'dense',
    })

    print('dungeon:')
    for k, v in pairs(dungeon) do
        print('- ' .. k .. ': ' .. tostring(v))
    end
    print()
end

function love.load(args)
    generate()
end

function love.keypressed(key, scancode)
    if key == 'g' then generate() end    
    if key == 'q' then love.event.quit() end
end