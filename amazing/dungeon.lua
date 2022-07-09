local PATH = (...):match("(.-)[^%.]+$") 
local prng = require(PATH .. '.prng')

require(PATH .. '.config')
require(PATH .. '.flags')
require(PATH .. '.util')

local random = prng.random

local function tostring(dungeon)
    local s = ''

    for row = 1, dungeon.n_rows do
        for col = 1, dungeon.n_cols do
            local v = dungeon.cell[row][col]

            if bit.band(v, Cell.PERIMETER) == Cell.PERIMETER then
                s = s .. '#'
            elseif bit.band(v, Cell.ROOM) == Cell.ROOM then
                s = s .. '.'
            else
                s = s .. ' '
            end
        end
        s = s .. '\n'
    end

    return s
end

local function init(params)
    if params.seed then
        prng.randomseed(seed)
    end

    local d_layout = DungeonLayout[params.dungeon_layout]
    local d_size = DungeonSize[params.dungeon_size]

    local n_i = math.floor(d_size.size * d_layout.aspect)
    local n_rows = 2 * n_i + 1

    local n_j = math.floor(d_size.size)
    local n_cols = 2 * n_j + 1

    local cell = {}

    for row = 1, n_rows do
        cell[row] = {}
        for col = 1, n_cols do
            cell[row][col] = Cell.NOTHING
        end
    end

    print(n_rows .. ' x ' .. n_cols)

    return {
        n_i = n_i,
        n_j = n_j,
        n_rows = n_rows,
        n_cols = n_cols,
        cell = cell
    }
end

local function createRoom(dungeon, params, room)
    local r_size = RoomSize[params.room_size]
    local base = r_size.base
    local radix = r_size.radix

    if not room.height then
        if room.i then
            local i = dungeon.n_i - room.i - base
            local r = math.min(i, radix)
            room.height = random(r) + base
        else
            room.height = random(radix) + base
        end
    end

    if not room.width then
        if room.j then
            local j = dungeon.n_j - room.j - base
            local r = math.min(j, radix)
            room.width = random(r) + base
        else
            room.width = random(radix) + base
        end
    end

    if not room.i then
        room.i = random(dungeon.n_i - room.height)
    end

    if not room.j then
        room.j = random(dungeon.n_j - room.width)
    end

    print(room.width, room.height)

    return room
end

local function testRoom(dungeon, room)
    local r1, r2 = room.i * 2 + 1, (room.i + room.height) * 2 + 1
    local c1, c2 = room.j * 2 + 1, (room.j + room.width) * 2 + 1

    for r = r1, r2 do
        for c = c1, c2 do
            if bit.band(dungeon.cell[r][c], Cell.ROOM) ~= 0 then
                return false
            end
        end
    end

    return true
end

local function placeRoom(dungeon, params, room)
    local room = createRoom(dungeon, params, room)
    
    local r1, r2 = room.i * 2 + 1, (room.i + room.height) * 2 - 1
    local c1, c2 = room.j * 2 + 1, (room.j + room.width) * 2 - 1

    if r1 < 1 or r2 > dungeon.n_rows - 1 then return end
    if c1 < 1 or c2 > dungeon.n_cols - 1 then return end

    if testRoom(dungeon, room) == false then return end

    for r = r1, r2 do
        for c = c1, c2 do
            dungeon.cell[r][c] = Cell.ROOM
        end
    end

    for r = r1 - 1, r2 + 1 do
        for _, c in ipairs({ c1 - 1, c2 + 1 }) do
            if bit.band(dungeon.cell[r][c], Cell.ROOM) == 0 then
                dungeon.cell[r][c] = bit.bor(dungeon.cell[r][c], Cell.PERIMETER)
            end
        end
    end

    for c = c1 - 1, c2 + 1 do
        for _, r in ipairs({ r1 - 1, r2 + 1 }) do
            if bit.band(dungeon.cell[r][c], Cell.ROOM) == 0 then
                dungeon.cell[r][c] = bit.bor(dungeon.cell[r][c], Cell.PERIMETER)
            end            
        end
    end
end

local function packRooms(dungeon, params)
    for i = 1, dungeon.n_i do
        local row = i * 2 + 1
        for j = 1, dungeon.n_j do
            local col = j * 2 + 1

            if bit.band(dungeon.cell[row][col], Cell.ROOM) == Cell.ROOM then
                goto continue
            end

            if oneIn(2) then goto continue end

            placeRoom(dungeon, params, { i = i, j = j })

            ::continue::
        end
    end
end

local function scatterRooms(dungeon, params)
    local is_sparse = RoomLayout[params.room_layout] == RoomLayout.sparse
    print('is_sparse', is_sparse)
end

local function addRooms(dungeon, params)
    local r_layout = RoomLayout[params.room_layout]
    local r_size = RoomSize[params.room_size]

    if r_layout == RoomLayout.dense then
        packRooms(dungeon, params)
    else
        scatterRooms(dungeon, params)
    end
end

return function(params)
    local dungeon = init(params)

    addRooms(dungeon, params)

    print(tostring(dungeon))

    return dungeon
end