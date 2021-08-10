local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Roact = require(Knit.Client.Lib.Roact)
local Themes = require(script:FindFirstAncestor("UIController").Themes)

local BoardPiece = Roact.Component:extend("BoardPiece")

local e = Roact.createElement

function BoardPiece:init()

end

function BoardPiece:render()
    local props = self.props
    local boardGuiState = props.BoardGuiState
    local isVisible = props.IsVisible
    local pieceName = props.PieceName
    local color = props.Color

    return e("ImageButton", {
        ["Image"] = boardGuiState.PieceTheme[color][pieceName],
        ["AnchorPoint"] = Vector2.new(0.5, 0.5),
        ["Position"] = UDim2.new(0.5, 0, 0.5, 0),
        ["Size"] = UDim2.new(0.7, 0, 0.7, 0),
        ["BackgroundTransparency"] = 1,
        ["Visible"] = isVisible == nil,
    })
end

return BoardPiece