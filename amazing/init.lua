local PATH = (...):gsub('%.init$', '')

local M = {
    _VERSION = "0.1.0",
    _DESCRIPTION = "A random dungeon generator",
    _URL = "https://github.com/wolf81/amazing",
    _LICENSE = [[ TBD ]], 
}

M.builder = require(PATH .. '.builder')
M.Tile = require(PATH .. '.tile')
M.Map = require(PATH .. '.map')
M.RandomTable = require(PATH .. '.random_table')
M.PriorityQueue = require(PATH .. '.pqueue')
M.dijkstra = require(PATH .. '.dijkstra')

return M