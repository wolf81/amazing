local PATH = (...):match("(.-)[^%.]+$") 
local prng = require(PATH .. '.prng')

require(PATH .. '.config')
require(PATH .. '.flags')
require(PATH .. '.util')
require(PATH .. '.direction')

local random = prng.random

local function tostring(dungeon)
    local s = ''

    for row = 0, dungeon.n_rows - 1 do
        for col = 0, dungeon.n_cols - 1 do
            local v = dungeon.cell[row][col]

            if bit.band(v, Cell.PERIMETER) == Cell.PERIMETER then
                s = s .. '#'
            elseif bit.band(v, Cell.ROOM) == Cell.ROOM then
                s = s .. ' '
            elseif bit.band(v, Mask.OPENSPACE) ~= 0 then
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
    local n_rows = 2 * n_i

    local n_j = math.floor(d_size.size)
    local n_cols = 2 * n_j

    local cell = {}

    for row = 0, n_rows do
        cell[row] = {}
        for col = 0, n_cols do
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

--[[ ROOM GENERATION ]]--

local function createRoom(dungeon, params, room)
    room = room or {}

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

    if r1 < 2 or r2 > dungeon.n_rows - 2 then return end
    if c1 < 2 or c2 > dungeon.n_cols - 2 then return end

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
    for i = 1, dungeon.n_i - 1 do
        local row = i * 2 + 1
        for j = 1, dungeon.n_j - 1 do
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

    local d_area = dungeon.n_rows * dungeon.n_cols
    local r_size = RoomSize[params.room_size]
    local r_area = math.pow((r_size.base + r_size.radix) * 2 + 1, 2)
    local n_rooms = math.floor(d_area / r_area)

    if is_sparse then n_rooms = n_rooms / 3 end

        print('rooms', n_rooms)
    for i = 1, n_rooms do
        placeRoom(dungeon, params)
    end
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

--[[ MAZE GENERATION ]]--

local function delveTunnel(dungeon, r1, c1, r2, c2)
    for r = r1, r2, (r1 < r2) and 1 or -1 do
        for c = c1, c2, (c1 < c2) and 1 or -1 do
            dungeon.cell[r][c] = bit.bor(dungeon.cell[r][c], Cell.CORRIDOR)
        end
    end
end

local function testTunnel(dungeon, r1, c1, r2, c2)
    if r1 < 1 or r2 > dungeon.n_rows then return false end
    if c1 < 1 or c2 > dungeon.n_cols then return false end

    for r = r1, r2, (r1 < r2) and 1 or -1 do
        for c = c1, c2, (c1 < c2) and 1 or -1 do
            if bit.band(dungeon.cell[r][c], Mask.BLOCK_CORR) ~= 0 then 
                return false 
            end
        end
    end

    return true
end

local function openTunnel(dungeon, i, j, dir)
    local di, dj = unpack(dir)

    local r1, c1 = i * 2 + 1, j * 2 + 1
    local r2, c2 = (i + di) * 2 + 1, (j + dj) * 2 + 1

    if testTunnel(dungeon, (r1 + r2) / 2, (c1 + c2) / 2, r2, c2) then
        delveTunnel(dungeon, r1, c1, r2, c2)
    end
end

local function tunnel(dungeon, i, j)
    local dirs = { 'north', 'south', 'west', 'east' }
    shuffle(dirs)

    for _, dir in ipairs(dirs) do
        if openTunnel(dungeon, i, j, Direction[dir]) then
            local di, dj = unpack(Direction[dir])
            tunnel(dungeon, i + di, j + dj)
        end
    end
end

local function addCorridors(dungeon, params)
    local i = random(dungeon.n_i)
    local j = random(dungeon.n_j)

    for i = 2, dungeon.n_i - 2 do
        local r = i * 2 + 1
        for j = 2, dungeon.n_j - 2 do
            local c = j * 2 + 1

            if bit.band(dungeon.cell[r][c], Cell.CORRIDOR) == 0 then 
                tunnel(dungeon, i, j)
            end
        end
    end
end

local function growMaze(dungeon, params)    
    local cells = {}
    for i = 1, dungeon.n_i do
        for j = 1, dungeon.n_j do
            cells[#cells + 1] = { i, j }
        end
    end

    local i, j = random(dungeon.n_i, dungeon.n_j)

    while #cells > 0 do
        local idx = random(#cells)
        local i, j = unpack(cells[idx])
        local r1, c1 = i * 2 + 1, j * 2 + 1

        local dirs = { Direction.north, Direction.south, Direction.east, Direction.west }
        shuffle(dirs)

        for _, dir in ipairs(dirs) do
            local di, dj = unpack(dir)
            local r2, c2 = (i + di) * 2 + 1, (j + dj) * 2 + 1

            if r2 < 0 or r2 > dungeon.n_rows then goto continue end
            if c2 < 0 or c2 > dungeon.n_cols then goto continue end

            local rm, cm = (r1 + r2) / 2, (c1 + c2) / 2

                    if bit.band(dungeon.cell[r2][c2], Mask.BLOCK_CORR) ~= 0 then goto continue end

            for r = rm, r2, rm < r2 and 1 or -1 do
                for c = cm, c2, cm < c2 and 1 or -1 do
                    local cell = dungeon.cell[r][c]

                    if bit.band(cell, Mask.BLOCK_CORR) ~= 0 then goto continue end
                    if bit.band(cell, Cell.ROOM) == Cell.ROOM then goto continue end

                    dungeon.cell[r][c] = bit.bor(cell, Cell.CORRIDOR)
                end
            end

            ::continue::
        end

        table.remove(cells, idx)
    end
end

--[[ INIT ]]--

return function(params)
    local dungeon = init(params)

    addRooms(dungeon, params)
    -- addCorridors(dungeon, params)

    growMaze(dungeon,params)
    
    print(tostring(dungeon))

    return dungeon
end