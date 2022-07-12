local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local random = love.math.random
local Map = require(PATH .. '.map')
local Rect = require(PATH .. '.rect')
local Tile = require(PATH .. '.tile')
local BuilderBase = require(PATH .. '.builder_base')

local CABuilder = {}
CABuilder.__index = BuilderBase

function CABuilder:build(params)
    local map = Map()

    local map_w, map_h = map.size()

    for y = 2, map_h - 1 do
        for x = 2, map_w - 1 do
            if random(1, 100) > 55 then
                map.set(x, y, Tile.FLOOR)
            end
        end
    end

    for _ = 1, 10 do
        local map_copy = map.copy()
        for y = 2, map_h - 2 do
            for x = 2, map_w - 2 do
                local neighbors = 0

                if map.get(x - 1, y) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x + 1, y) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x, y - 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x, y + 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x - 1, y - 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x - 1, y + 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x + 1, y - 1) == Tile.WALL then neighbors = neighbors + 1 end
                if map.get(x + 1, y + 1) == Tile.WALL then neighbors = neighbors + 1 end

                if neighbors > 4 or neighbors == 0 then
                    map_copy.set(x, y, Tile.WALL)
                else
                    map_copy.set(x, y, Tile.FLOOR)
                end
            end
        end

        map = map_copy
    end

--[[
 // Now we iteratively apply cellular automata rules
    for _i in 0..15 {
        let mut newtiles = self.map.tiles.clone();

        for y in 1..self.map.height-1 {
            for x in 1..self.map.width-1 {
                let idx = self.map.xy_idx(x, y);
                let mut neighbors = 0;
                if self.map.tiles[idx - 1] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx + 1] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx - self.map.width as usize] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx + self.map.width as usize] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx - (self.map.width as usize - 1)] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx - (self.map.width as usize + 1)] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx + (self.map.width as usize - 1)] == TileType::Wall { neighbors += 1; }
                if self.map.tiles[idx + (self.map.width as usize + 1)] == TileType::Wall { neighbors += 1; }

                if neighbors > 4 || neighbors == 0 {
                    newtiles[idx] = TileType::Wall;
                }
                else {
                    newtiles[idx] = TileType::Floor;
                }
            }
        }
        --]]

    return map
end

return CABuilder
