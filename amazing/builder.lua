local PATH = (...):match("(.-)[^%.]+$") 

local BuilderChain = require(PATH .. '.builder_chain')

local SimpleBuilder = require(PATH .. '.builder_simple')
local BSPBuilder = require(PATH .. '.builder_bsp')
local CABuilder = require(PATH .. '.builder_ca')
local MazeBuilder = require(PATH .. '.builder_maze')
local HiveBuilder = require(PATH .. '.builder_hive')
local PrefabBuilder = require(PATH .. '.builder_prefab')
local DrunkardBuilder = require(PATH .. '.builder_drunkard')

local RoomDecorator = require(PATH .. '.decorator_room')
local DoorDecorator = require(PATH .. '.decorator_door')
local StairDecorator = require(PATH .. '.decorator_stair')
local CullUnreachableDecorator = require(PATH .. '.decorator_cull_unreachable')
local NearestCorridorDecorator = require(PATH .. '.decorator_corridor_nearest')

local lrandom = love.math.random

local function bsp(params)
    return BuilderChain(BSPBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
    })
end

local function simple(params)
    return BuilderChain(SimpleBuilder, { 
        RoomDecorator,
        NearestCorridorDecorator,
        DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
    })    
end

local function ca(params)
    return BuilderChain(CABuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
    })
end

local function maze(params)
    return BuilderChain(MazeBuilder, { 
        CullUnreachableDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
    })
end

local function hive(params)
    return BuilderChain(HiveBuilder, { 
        CullUnreachableDecorator,
        DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,        
    })
end

local function prefab(params)
    return BuilderChain(PrefabBuilder, { 
        -- CullUnreachableDecorator,
        -- DoorDecorator,
        -- StairDecorator,
    }, {
        ['random_table'] = params.random_table,
        ['map'] = params.map, -- required!
    })    
end

local function open_halls(params)
    return BuilderChain(DrunkardBuilder, { 
        CullUnreachableDecorator,
        -- DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
        ['drunk_life'] = 400,
        ['spawn_mode'] = 'center',
        ['floor_pct']  = 0.5,
    })
end

local function open_area(params)
    return BuilderChain(DrunkardBuilder, { 
        CullUnreachableDecorator,
        -- DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
        ['drunk_life'] = 400,
        ['spawn_mode'] = 'random',
        ['floor_pct']  = 0.5,
    })
end

local function winding_passages(params)
    return BuilderChain(DrunkardBuilder, { 
        CullUnreachableDecorator,
        -- DoorDecorator,
        StairDecorator,
    }, {
        ['random_table'] = params.random_table,
        ['drunk_life'] = 100,
        ['spawn_mode'] = 'random',
        ['floor_pct']  = 0.4,
    })
end

local function drunkard(params)
    local builders = { open_area, open_halls, winding_passages }
    return builders[lrandom(#builders)](params)
end

local function random(params)
    local builders = { maze, simple, bsp, ca, hive, drunkard }
    return builders[love.math.random(#builders)](params)
end

return {
    random = random,
    ca = ca,
    bsp = bsp,
    hive = hive,
    maze = maze,
    simple = simple,
    prefab = prefab,
    open_area = open_area,
    open_halls = open_halls,
    winding_passages = winding_passages,
}
