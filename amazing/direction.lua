--[[ DIRECTION ]]--

-- constants
local Direction = {
    N = 0x1,
    S = 0x2,
    E = 0x4,
    W = 0x8,
}

-- opposite direction table
Direction.opposite = {
    [Direction.E] = Direction.W, 
    [Direction.W] = Direction.E, 
    [Direction.N] = Direction.S, 
    [Direction.S] = Direction.N,
}

-- get direction heading as a vector
Direction.heading = {
    [Direction.E] = { x =  1, y =  0 },
    [Direction.W] = { x = -1, y =  0 },
    [Direction.N] = { x =  0, y = -1 },
    [Direction.S] = { x =  0, y =  1 },
}

return Direction