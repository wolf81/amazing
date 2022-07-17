local PATH = (...):match("(.-)[^%.]+$") 

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')
local CABuilder = require(PATH .. '.builder_ca')
local MazeBuilder = require(PATH .. '.builder_maze')
local HiveBuilder = require(PATH .. '.builder_hive')
local BuilderChain = require(PATH .. '.builder_chain')
local RoomDecorator = require(PATH .. '.decorator_room')
local CullUnreachableDecorator = require(PATH .. '.decorator_cull_unreachable')
local StairsDecorator = require(PATH .. '.decorator_stairs')
local NearestCorridorDecorator = require(PATH .. '.decorator_corridor_nearest')
local DoorDecorator = require(PATH .. '.decorator_door')

local function bsp()
    return BuilderChain(BSPBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        StairsDecorator,
    })
end

local function simple()
    return BuilderChain(SimpleBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        StairsDecorator,
    })
end

local function ca()
    return BuilderChain(CABuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        StairsDecorator,
    })
end

local function maze()
    return BuilderChain(MazeBuilder, { 
        CullUnreachableDecorator,
        StairsDecorator,
    })
end

local function hive()
    return BuilderChain(HiveBuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        StairsDecorator,
    })
end

local function random()
    local builders = { maze(), simple(), bsp(), ca(), hive() }
    return builders[love.math.random(#builders)]
end

return {
    random = random,
    simple = simple,
    bsp = bsp,
    ca = ca,
}
