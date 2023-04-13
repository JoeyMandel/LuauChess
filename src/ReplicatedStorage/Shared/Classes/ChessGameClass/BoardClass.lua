local BoardClass = {}
BoardClass.__index = BoardClass


function BoardClass.new()
    local self = setmetatable({
        ["Map"] = table.create(64, false)
    }, BoardClass)
    return self
end

function BoardClass:SetRow(row, value)
    for x = 0, 7 do
        self:SetValueAt(
            self.PosToIndex(x, row),
            value
        )
    end
end

function BoardClass:SetValueAt(index, target)
    self.Map[index] = target
end

function BoardClass:GetValueAt(index)
    return self.Map[index]
end

function BoardClass.IndexToPos(index)
    return math.floor(index / 8), index  % 8
end

function BoardClass.PosToIndex(x, y)
    return x * 8 + y
end

return BoardClass
