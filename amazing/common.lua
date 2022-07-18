local PATH = (...):match("(.-)[^%.]+$") 

Tile = require(PATH .. '.tile')
Map = require(PATH .. '.map')
Rect = require(PATH .. '.rect')
Direction = require(PATH .. '.direction')

BuilderBase = require(PATH .. '.builder_base')
DecoratorBase = require(PATH .. '.decorator_base')

PriorityQueue = require(PATH .. '.pqueue')
Dijkstra = require(PATH .. '.dijkstra')

require(PATH .. '.util')
