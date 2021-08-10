local Knit = require(game:GetService("ReplicatedStorage").Knit)
local TableUtil = require(Knit.Shared.Lib.TableUtil)

local Roact = require(Knit.Client.Lib.Roact)
local e = Roact.createElement

local Themes = require(Knit.Client.Controllers.UIController.Themes)
local BoardColumn = require(script.Parent.BoardColumn)

local BoardContainer = Roact.Component:extend("BoardContainer")

function BoardContainer:init()

end

function BoardContainer:didMount()
    
end

function BoardContainer:render()
    local props = self.props
    
    local children = {}

    local columns = {}

    columns["ListLayout"] = e("UIListLayout", {
        ["FillDirection"] = Enum.FillDirection.Horizontal,
        ["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
        ["SortOrder"] = Enum.SortOrder.LayoutOrder,
        ["VerticalAlignment"] = Enum.VerticalAlignment.Top,
    })


    for x = 1,8 do
        local childProps = TableUtil.CopyShallow(props)
        childProps.ColumnNumber = x
        table.insert(columns, e(BoardColumn, childProps))
    end

    children["Container"] = e("Frame", {
        ["Size"] = UDim2.new(1, 0, 1, 0),
        ["Position"] = UDim2.new(0.5, 0, 0.5, 0),

        ["BackgroundTransparency"] = 1,
        ["AnchorPoint"] = Vector2.new(0.5, 0.5),
    }, columns)

    children["Backdrop"] =  e("Frame", {
        ["Size"] = UDim2.new(1.05, 0, 1.05, 0),
        ["Position"] = UDim2.new(0.5, 0, 0.5, 0),

        ["BackgroundColor3"] = Color3.fromRGB(0, 0, 0),
        ["BackgroundTransparency"] = 0.9,
        ["AnchorPoint"] = Vector2.new(0.5, 0.5),
        ["BorderSizePixel"] = 0,
        ["ZIndex"] = -1,
    })


    return e("Frame", {
        ["Size"] = UDim2.new(0.6, 0, 0.6, 0),
        ["Position"] = UDim2.new(0.35, 0,0.5, 0),
        ["AnchorPoint"] = Vector2.new(0.5, 0.5),

        ["SizeConstraint"] = Enum.SizeConstraint.RelativeYY,
        ["BackgroundTransparency"] = 1,
    }, children)
end

return BoardContainer