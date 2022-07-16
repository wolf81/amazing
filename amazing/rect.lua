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

    self.copy = function() return Rect(x, y, w, h) end

    self.inset = function(x1, y1, x2, y2)
        self.x1 = self.x1 + x1
        self.y1 = self.y1 + y1
        self.x2 = self.x2 + x2
        self.y2 = self.y2 + y2

        mid_x = round((self.x1 + self.x2) / 2)
        mid_y = round((self.y1 + self.y2) / 2)

        return self
    end

    self.iter = function()
        local x, y = self.x1, self.y1

        return function()
            while true do
                x = x + 1

                if x > self.x2 then
                    y = y + 1
                    x = self.x1
                end

                if y > self.y2 then break end

                return x, y
            end

            return nil
        end
    end

    return readOnly(self)
end

return setmetatable(Rect, {
    __call = function(_, x, y, w, h) return new(x, y, w, h) end,
})
