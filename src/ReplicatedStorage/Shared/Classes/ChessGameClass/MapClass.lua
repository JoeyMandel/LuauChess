local MapClass = {}
MapClass.__index = MapClass


function MapClass.new()
    local self = setmetatable({
        ["Map"] = table.create(64, false)
    }, MapClass)
    return self
end

function MapClass:SetValueAt(index, target)
    self.Map[index] = target
end

function MapClass:GetValueAt(index)
    return self.Map[index]
end

function MapClass.IndexToPos(index)
    return index  % 8, math.floor(index / 8)
end

function MapClass.PosToIndex(x, y)
    return y * 8 + x
end

return MapClass
