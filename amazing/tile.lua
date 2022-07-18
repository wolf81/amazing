--[[ TILE FLAGS ]]--

local Tile = {
    NOTHING     = 0x0,
    BLOCKED     = 0x1,
    FLOOR       = 0x2,
    WALL        = 0x4,
    DOOR        = 0x8,
    STAIR_DN    = 0x10,
    STAIR_UP    = 0x20,
}

return Tile
