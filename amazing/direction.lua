Direction = {
    north = { -1,  0 },
    south = {  1,  0 },
    east  = {  0,  1 },
    west  = {  0, -1 },
}

local opposite = {
    [Direction.north] = Direction.south,
    [Direction.south] = Direction.north,
    [Direction.east] = Direction.west,
    [Direction.west] = Direction.east,
}

Direction.opposite = function(dir)
    return opposite[dir]
end
