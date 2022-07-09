io.stdout:setvbuf('no') -- show debug output live in SublimeText console

local amazing = require 'amazing'

function love.load(args)
    local dungeon = amazing.dungeon({
        seed = os.time(),
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

    love.event.quit()
end