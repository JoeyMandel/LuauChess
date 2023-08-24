local MapClass = {}
MapClass.__index = MapClass


function MapClass.new()
    local self = setmetatable({
        ["Map"] = table.create(63, false)
    }, MapClass)

    self.Map[0] = false
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

function MapClass:Visualize()
    local text = "\n"

    for index = 0, 63 do
        local shouldAddNewLine = ((index + 1) % 8) == 0
        local value = self:GetValueAt(index)
        local character = tostring(value) .. " "

        if value == false then
            character = "- "
        elseif value == true then
            character = "# "
        end

        text = text .. character
        
        if shouldAddNewLine then
            text = text .. "\n"
        end
    end
    print(text)
end

return MapClass
