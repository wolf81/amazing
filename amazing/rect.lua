local PATH = (...):match("(.-)[^%.]+$") 

require(PATH .. '.util')

local Rect = {}

local function new(x, y, w, h)
    local self = {
        x1 = x,
        y1 = y,
        x2 = x + w,
        y2 = y + h,
    }

    local mid_x = round((self.x1 + self.x2) / 2)
    local mid_y = round((self.y1 + self.y2) / 2)

    self.intersect = function(other)
        return (
            self.x1 <= other.x2 and 
            self.x2 >= other.x1 and
            self.y1 <= other.y2 and
            self.y2 >= other.y1
        )
    end
    
    self.center = function() return mid_x, mid_y end    

    return readOnly(self)
end

return setmetatable(Rect, {
    __call = function(_, x, y, w, h) return new(x, y, w, h) end,
})
