local BitBoardClass = {}
BitBoardClass.__index = BitBoardClass


function BitBoardClass.new()
    local self = setmetatable({
        ["Map"] = table.create(64, false)
    }, BitBoardClass)
    return self
end

function BitBoardClass:SetRow(row, value)
    for x = 0, 7 do
        self:SetValueAt(
            self.PosToIndex(x, row),
            value
        )
    end
end

function BitBoardClass:SetValueAt(index, target)
    self.Map[index] = target
end

function BitBoardClass:GetValueAt(index)
    return self.Map[index]
end

function BitBoardClass.IndexToPos(index)
    return math.floor(index / 8), index  % 8
end

function BitBoardClass.PosToIndex(x, y)
    return x * 8 + y
end

return BitBoardClass
