local Knit = require(game:GetService("ReplicatedStorage").Knit)

local TableUtil = require(Knit.Shared.Lib.TableUtil)

local Roact = require(Knit.Client.Lib.Roact)

local BoardTile = require(script.Parent.BoardTile)

local BoardColumn = Roact.PureComponent:extend("BoardColumn")

local e = Roact.createElement

function BoardColumn:init()
    local props = self.props
    local BoardStore = props.Board
    local BoardGuiStore = props.BoardGuiStore

    BoardGuiStore.changed:connect(function(newState, lastState)
        self:setState(function(prevState)
            prevState.BoardGuiInfo = newState
            return prevState
        end)
    end)


    BoardStore.changed:connect(function(newState)
        self:setState(function(prevState)
            prevState.BoardState = newState
            return prevState
        end)
    end)

    self:setState({
        ["BoardState"] = BoardStore:getState(),
        ["BoardGuiInfo"] = BoardGuiStore:getState(),
    })
end

function BoardColumn:didMount()
end

function BoardColumn:render()
    local props = self.props 
    local x = props.ColumnNumber

    local boardState = self.state.BoardGuiInfo
    local isFlipped = boardState.IsFlipped

    local children = {
        ["ListLayout"] = e("UIListLayout", {
            ["FillDirection"] = Enum.FillDirection.Vertical,
            ["HorizontalAlignment"] = Enum.HorizontalAlignment.Left,
            ["SortOrder"] = Enum.SortOrder.LayoutOrder,
            ["VerticalAlignment"] = Enum.VerticalAlignment.Top,
        })
    }

    for y = 1, 8  do
        local childProps = TableUtil.CopyShallow(props)
        childProps.RowNumber = y
        table.insert(children, e(BoardTile, childProps))
    end

    print(isFlipped)
    return e("Frame", {
        ["Size"] = UDim2.new(1/8, 0, 1, 0),
        ["LayoutOrder"] = isFlipped and 8 - x or x ,
        ["Transparency"] = 1,
    }, children)
end

return BoardColumn