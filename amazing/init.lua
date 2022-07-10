local PATH = (...):gsub('%.init$', '')

local M = {
    _VERSION = "0.1.0",
    _DESCRIPTION = "A random dungeon generator",
    _URL = "https://github.com/wolf81/amazing",
    _LICENSE = [[
    ]], 
}

M.dungeon = require(PATH .. '.dungeon')

return M