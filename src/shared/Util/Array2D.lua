-- wafflechad
-- memory continuous 2d array

export type Array2D<t> = {t}

local Array2D = {}

local Array2DContext = {}
Array2DContext.__index = Array2DContext

function Array2DContext.new(sizeX, sizeY)
    local self = setmetatable({}, Array2DContext)
    self.sizeX = sizeX
    self.sizeY = sizeY
    return self
end

Array2D.newContext = Array2DContext.new

function Array2DContext:create<T>(set: T): Array2D<T>
    return Array2D.create(self.sizeX, self.sizeY, set)
end

function Array2DContext:set<T>(array: Array2D<T>, x, y, set: T)
    return Array2D.set(array, self.sizeX, self.sizeY, x, y, set)
end

function Array2DContext:get<T>(array: Array2D<T>, x, y): T
    return Array2D.get(array, self.sizeX, self.sizeY, x, y)
end

function Array2D.create<T>(sizeX, sizeY, set): Array2D<T>
    return table.create(sizeX * sizeY , set)
end

function Array2D.set<T>(array: Array2D<T>, sizeX, sizeY, x, y, set: T)
    array[sizeY * (y - 1) + x] = set
end

function Array2D.get<T>(array: Array2D<T>, sizeX, sizeY, x, y)
    return array[sizeY * (y - 1) + x]
end

-- most complicated algorithm in the world right here
function Array2D.rotateDimension(x, y, r)
    if r == 0 then
        return x, y
    else
        return y, x
    end
end

return Array2D