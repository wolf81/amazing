Cell = {
    NOTHING     = 0x0,
    BLOCKED     = 0x1,
    ROOM        = 0x2,
    CORRIDOR    = 0x4,
    PERIMETER   = 0x10,
}

Mask = {
    OPENSPACE   = bit.bor(Cell.ROOM, Cell.CORRIDOR),
    BLOCK_CORR  = bit.bor(Cell.BLOCKED, Cell.PERIMETER, Cell.CORRIDOR),
}