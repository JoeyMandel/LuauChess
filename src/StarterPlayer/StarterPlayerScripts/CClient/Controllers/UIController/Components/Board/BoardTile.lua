-- TO-DO Be able to rotate the board

local Knit = require(game:GetService("ReplicatedStorage").Knit)
local TableUtil = require(Knit.Shared.Lib.TableUtil)
local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local NumberLabel = require(script.Parent.TileNumberLabel)
local BoardPiece = require(script.Parent.BoardPiece)

local Roact = require(Knit.Client.Lib.Roact)
local e = Roact.createElement

local BoardTile = Roact.PureComponent:extend("BoardContainer")

function BoardTile:init()
    local props = self.props
    local BoardStore = props.Board
    local BoardGuiStore = props.BoardGuiStore


    BoardGuiStore.changed:connect(function(newState)
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

function BoardTile:didMount()

end

function BoardTile:render()
    local props = self.props

    local x = props.ColumnNumber
    local y = props.RowNumber

    local appInfo = self.state.AppInfo
    local boardState = self.state.BoardGuiInfo
    local boardTheme = boardState.BoardTheme

    local isFlipped = boardState.IsFlipped

    local tileState = self.state.BoardState[BoardUtil.Vector2ToInt(x,y)]

    local children = {}

    if isFlipped then
        if (x == 8) then
            table.insert(children, e(NumberLabel, {
                ["TextColor"] = tileState.IsDark and boardTheme.Light or boardTheme.Dark,
                ["Number"] = y,
                ["IsLeft"] = true,
            }))
        end

        if (y == 8) then
            table.insert(children, e(NumberLabel, {
                ["TextColor"] = tileState.IsDark and boardTheme.Light or boardTheme.Dark,
                ["Number"] = tileState.File,
                ["IsLeft"] = false,
            }))
        end  
    else
        if (x == 1) then
            table.insert(children, e(NumberLabel, {
                ["TextColor"] = tileState.IsDark and boardTheme.Light or boardTheme.Dark,
                ["Number"] = y,
                ["IsLeft"] = true,
            }))
        end

        if (y == 1) then
            table.insert(children, e(NumberLabel, {
                ["TextColor"] = tileState.IsDark and boardTheme.Light or boardTheme.Dark,
                ["Number"] = tileState.File,
                ["IsLeft"] = false,
            }))
        end
    end
    
    if tileState.Piece then
        print(tileState.Piece.Type)
        children["Piece"] = e(BoardPiece, {
            ["PieceName"] = tileState.Piece.Type, 
            ["BoardGuiState"] = boardState,
            ["Color"] = BoardUtil.GetColor(tileState.Piece.IsBlack),
            ["IsVisible"] = BoardUtil.Get(boardState.InvisiblePieces, Vector2.new(x, y))
        }) 
    end
    -- table.insert(children, e)
    local tileProperties = {
        ["Size"] = UDim2.new(1, 0,1/8, 0),
        ["AnchorPoint"] = Vector2.new(0.5, 0.5),
        ["SizeConstraint"] = Enum.SizeConstraint.RelativeXY,
        ["BackgroundColor3"] = tileState.IsDark and boardTheme.Dark or boardTheme.Light,
        ["LayoutOrder"] = isFlipped and  8  or 8 - y,
        ["BorderSizePixel"] = 0,
    }

    return e("Frame", tileProperties, children)
end

return BoardTile