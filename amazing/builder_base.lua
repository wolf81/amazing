local PATH = (...):match("(.-)[^%.]+$") 

local Map = require(PATH .. '.map')
local Tile = require(PATH .. '.tile')

--[[ COMMON ]]--

function applyHorizontalTunnel(map, x1, x2, y)
    for x = x1, x2, x1 < x2 and 1 or -1 do
        map.set(x, y, Tile.ROOM)
    end
end

function applyVerticalTunnel(map, y1, y2, x)
    for y = y1, y2, y1 < y2 and 1 or -1 do
        map.set(x, y, Tile.ROOM)
    end
end

function applyRoom(map, room)
    for y = room.y1 + 1, room.y2 do
        for x = room.x1 + 1, room.x2 do
            map.set(x, y, Tile.ROOM)
        end
    end
end

--[[ BUILDER BASE ]]

local BuilderBase = {}
BuilderBase.__index = BuilderBase

function BuilderBase:new(tbl)
    self = tbl or {}
    return setmetatable(tbl, BuilderBase)
end

function BuilderBase:build()
    return Map()
end

return setmetatable(BuilderBase, {
    __call = BuilderBase.new,
})
