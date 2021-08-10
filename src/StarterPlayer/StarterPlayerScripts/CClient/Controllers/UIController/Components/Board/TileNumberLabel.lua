local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Roact = require(Knit.Client.Lib.Roact)


local e = Roact.createElement

return function(props)

    local textColor = props.TextColor
    local number = props.Number
    local isLeft = props.IsLeft

    return e("TextLabel", {
        ["Text"] = tostring(number),
        ["Position"] = isLeft and UDim2.new(0, 0, 0, 0) or UDim2.new(0.8, 0, 0.8, 0),
        ["Size"] = UDim2.new(0.2, 0, 0.2, 0),

        ["Font"] = Enum.Font.ArialBold,
        ["BackgroundTransparency"] = 1,
        ["TextColor3"] = textColor,
        ["TextScaled"] = true,
    })
end
