local PATH = (...):gsub('%.init$', '')

require(PATH .. '.common')

local M = {
    _VERSION = "0.1.0",
    _DESCRIPTION = "A random dungeon generator",
    _URL = "https://github.com/wolf81/amazing",
    _LICENSE = [[ TBD ]], 
}

M.builder = require(PATH .. '.builder')
M.Tile = Tile
M.Map = Map
M.RandomTable = RandomTable

return M