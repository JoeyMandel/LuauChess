local MapClass = {}
MapClass.__index = MapClass


function MapClass.new()
    local self = setmetatable({
        ["Map"] = table.create(64, false)
    }, MapClass)
    return self
end

function MapClass:SetRow(row, value)
    for x = 0, 7 do
        self:SetValueAt(
            self.PosToIndex(x, row),
            value
        )
    end
end

function MapClass:SetValueAt(index, target)
    self.Map[index] = target
end

function MapClass:GetValueAt(index)
    return self.Map[index]
end

function MapClass.IndexToPos(index)
    return math.floor(index / 8), index  % 8
end

function MapClass.PosToIndex(x, y)
    return x * 8 + y
end

return MapClass
