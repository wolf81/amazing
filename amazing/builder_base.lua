local PATH = (...):match("(.-)[^%.]+$") 

local Map = require(PATH .. '.map')
local Tile = require(PATH .. '.tile')

--[[ BUILDER BASE CLASS ]]--

local BuilderBase = {}
BuilderBase.__index = BuilderBase

function BuilderBase:new(tbl)
    self = tbl or {}
    return setmetatable(tbl, BuilderBase)
end

function BuilderBase:build()
    error('should be implemented by subclasses')
end

return setmetatable(BuilderBase, {
    __call = BuilderBase.new,
})
