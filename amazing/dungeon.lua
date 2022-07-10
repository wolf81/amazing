local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.config')
require(PATH .. '.flags')
require(PATH .. '.util')
require(PATH .. '.direction')

local prng = require(PATH .. '.prng')
local random = prng.random

local function tostring(dungeon)
    local s = ''

    for row = 1, dungeon.n_rows do
        for col = 1, dungeon.n_cols do
            local v = dungeon.cell[row][col]

            if bit.band(v, Cell.PERIMETER) == Cell.PERIMETER then
                s = s .. '#'
            elseif bit.band(v, Cell.CORRIDOR) == Cell.CORRIDOR then
                s = s .. ' '
            else
                s = s .. '#'
            end
        end
        s = s .. '\n'
    end

    return s
end

local function computeSeed(seed)
    if seed == nil then
        seed = os.time()
    elseif type(seed) == 'string' then
        local s = 42
        for i = 1, #seed do
            local char = string.sub(seed, i, i)
            s = bit.lshift(s, 5) - s + string.byte(char)
            s = bit.band(s, 0x7FFFFFFF)
        end
        seed = s
    end

    return seed
end

local function init(params)
    local seed = computeSeed(params.seed)
    print('seed', seed)
    prng.setRandomSeed(seed)

    local d_layout = DungeonLayout[params.dungeon_layout]
    local d_size = DungeonSize[params.dungeon_size]

    local n_i = math.floor(d_size.size * d_layout.aspect)
    local n_rows = 2 * n_i + 1

    local n_j = d_size.size
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

local function getRandomDirection()
    return shuffle({ Direction.north, Direction.south, Direction.east, Direction.west })
end

--[[ GROW MAZE (GROWING TREE ALGORITHM) ]]--
-- see: https://weblog.jamisbuck.org/2011/1/27/maze-generation-growing-tree-algorithm
local function growMaze(dungeon, params)
    local cell = dungeon.cell

    -- pick a random start position & add to list of visited cells
    local i, j = random(dungeon.n_i), random(dungeon.n_j)
    local cells = {{ i, j }}

    -- calculate actual cell position
    local row, col = i * 2 + 1, j * 2 + 1
    cell[row][col] = bit.bor(cell[row][col], Cell.CORRIDOR)

    -- until the visited cell list is empty ...
    while #cells > 0 do
        -- grab a random cell from the list of visited cells
        local cell_idx = random(#cells)
        local i, j = unpack(cells[cell_idx])

        -- choose a random direction
        for _, dir in ipairs(getRandomDirection(last_dir)) do
            -- calculate next position based on current position and direction
            local di, dj = unpack(dir)
            local i2, j2 = i + di, j + dj

            -- make sure the next position is within bounds
            if i2 < 0 or i2 > dungeon.n_i then goto continue end
            if j2 < 0 or j2 > dungeon.n_j then goto continue end

            -- calculate next position based on current position and direction
            -- make sure we haven't visited the next position already
            local r2, c2 = (i + di) * 2 + 1, (j + dj) * 2 + 1
            if bit.band(cell[r2][c2], Cell.CORRIDOR) ~= Cell.CORRIDOR then
                -- now add corridors: (r1, c1) → (r_mid, c_mid) -> (r2, c2)
                -- skip r1, c1 as this is the position we came from 
                local r1, c1 = i * 2 + 1, j * 2 + 1
                local r_mid, c_mid = (r1 + r2) / 2, (c1 + c2) / 2 

                cell[r_mid][c_mid] = bit.bor(cell[r_mid][c_mid], Cell.CORRIDOR)
                cell[r2][c2] = bit.bor(cell[r2][c2], Cell.CORRIDOR)

                -- add next position to visited list
                table.insert(cells, { i2, j2 })

                -- clear index to prevent removal of position from visited list
                cell_idx = nil

                -- skip remaining directions
                goto continue
            end

            ::continue::
        end

        -- remove position from visited list if all directions have been 
        -- processed
        if cell_idx then table.remove(cells, cell_idx) end
    end
end

local function shrinkMaze(dungeon, params, sparseness)
    local cell = dungeon.cell

    local dirs = { Direction.north, Direction.south, Direction.east, Direction.west }

    for i = 1, sparseness do
        for r1 = 1, dungeon.n_rows do
            for c1 = 1, dungeon.n_cols do
                local n_exit = 0

                for _, dir in ipairs(dirs) do
                    local di, dj = unpack(dir)
                    local r2, c2 = r1 + di, c1 + dj

                    if r2 < 1 or r2 > dungeon.n_rows then goto continue end
                    if c2 < 1 or c2 > dungeon.n_cols then goto continue end

                    if bit.band(cell[r2][c2], Cell.CORRIDOR) == Cell.CORRIDOR then
                        n_exit = n_exit + 1
                    end

                    ::continue::
                end

                if n_exit == 1 then
                    cell[r1][c1] = Cell.NOTHING
                end
            end
        end
    end
end

--[[ GENERATOR ]]--

return function(params)
    local dungeon = init(params)

    -- addRooms(dungeon, params)
    -- addCorridors(dungeon, params)

    growMaze(dungeon,params)
    shrinkMaze(dungeon, params, 0)
    
    print(tostring(dungeon))

    return dungeon
end