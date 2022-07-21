local PATH = (...):match("(.-)[^%.]+$") 

local BuilderChain = require(PATH .. '.builder_chain')

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')
local CABuilder = require(PATH .. '.builder_ca')
local MazeBuilder = require(PATH .. '.builder_maze')
local HiveBuilder = require(PATH .. '.builder_hive')
local DrunkardBuilder = require(PATH .. '.builder_drunkard')

local RoomDecorator = require(PATH .. '.decorator_room')
local DoorDecorator = require(PATH .. '.decorator_door')
local StairDecorator = require(PATH .. '.decorator_stair')
local CullUnreachableDecorator = require(PATH .. '.decorator_cull_unreachable')
local NearestCorridorDecorator = require(PATH .. '.decorator_corridor_nearest')

local lrandom = love.math.random

local function bsp(random_table)
    return BuilderChain(BSPBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
    })
end

local function simple(random_table)
    return BuilderChain(SimpleBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
    })    
end

local function ca(random_table)
    return BuilderChain(CABuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
    })
end

local function maze(random_table)
    return BuilderChain(MazeBuilder, { 
        CullUnreachableDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
    })
end

local function hive(random_table)
    return BuilderChain(HiveBuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,        
    })
end

local function open_halls(random_table)
    return BuilderChain(DrunkardBuilder, { 
        CullUnreachableDecorator,
        -- DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
        ['drunk_life'] = 400,
        ['spawn_mode'] = 'center',
        ['floor_pct']  = 0.5,
    })
end

local function open_area(random_table)
    return BuilderChain(DrunkardBuilder, { 
        CullUnreachableDecorator,
        -- DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
        ['drunk_life'] = 400,
        ['spawn_mode'] = 'random',
        ['floor_pct']  = 0.5,
    })
end

local function winding_passages(random_table)
    return BuilderChain(DrunkardBuilder, { 
        CullUnreachableDecorator,
        -- DoorDecorator,
        StairsDecorator,
    }, {
        ['random_table'] = random_table,
        ['drunk_life'] = 100,
        ['spawn_mode'] = 'random',
        ['floor_pct']  = 0.4,
    })
end

local function drunkard(random_table)
    local builders = { open_area, open_halls, winding_passages }
    return builders[lrandom(#builders)](random_table)
end

local function random(random_table)
    local builders = { maze, simple, bsp, ca, hive, drunkard }
    return builders[love.math.random(#builders)](random_table)
end

return {
    random = random,
    simple = simple,
    bsp = bsp,
    ca = ca,
    hive = hive,
    maze = maze,
    winding_passages = winding_passages,
    open_area = open_area,
    open_halls = open_halls,
}
