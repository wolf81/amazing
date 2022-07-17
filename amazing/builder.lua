local PATH = (...):match("(.-)[^%.]+$") 

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')
local CABuilder = require(PATH .. '.builder_ca')
local MazeBuilder = require(PATH .. '.builder_maze')
local BuilderChain = require(PATH .. '.builder_chain')
local RoomDecorator = require(PATH .. '.decorator_room')
local RoomStairsDecorator = require(PATH .. '.decorator_room_stairs')
local CullUnreachableDecorator = require(PATH .. '.decorator_cull_unreachable')
local AreaStairsDecorator = require(PATH .. '.decorator_area_stairs')
local NearestCorridorDecorator = require(PATH .. '.decorator_corridor_nearest')
local DoorDecorator = require(PATH .. '.decorator_door')

local function bsp()
    return BuilderChain(BSPBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        RoomStairsDecorator,
    })
end

local function simple()
    return BuilderChain(SimpleBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        RoomStairsDecorator,
    })
end

local function ca()
    return BuilderChain(CABuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        AreaStairsDecorator,
    })
end

local function maze()
    return BuilderChain(MazeBuilder, { 
        CullUnreachableDecorator,
        AreaStairsDecorator,
    })
end

local function random()
    local builders = { maze(), simple(), bsp(), ca() }
    return builders[love.math.random(#builders)]
end

return {
    random = random,
    simple = simple,
    bsp = bsp,
    ca = ca,
}
