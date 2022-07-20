local PATH = (...):match("(.-)[^%.]+$") 

Tile = require(PATH .. '.tile')
Map = require(PATH .. '.map')
Rect = require(PATH .. '.rect')
Direction = require(PATH .. '.direction')

BuilderBase = require(PATH .. '.builder_base')
DecoratorBase = require(PATH .. '.decorator_base')

RandomTable = require(PATH .. '.random_table')
Spawner = require(PATH .. '.spawner')

PriorityQueue = require(PATH .. '.pqueue')
Dijkstra = require(PATH .. '.dijkstra')

require(PATH .. '.util')
