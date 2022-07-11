local PATH = (...):gsub('%.init$', '')

local M = {
    _VERSION = "0.1.0",
    _DESCRIPTION = "A random dungeon generator",
    _URL = "https://github.com/wolf81/amazing",
    _LICENSE = [[
    ]], 
}

M.builder = require(PATH .. '.builder')
M.Tile = require(PATH .. '.tile')

return M