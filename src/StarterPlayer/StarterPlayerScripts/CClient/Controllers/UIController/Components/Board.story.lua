local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Roact = require(Knit.Client.Lib.Roact)
local Thread = require(Knit.Shared.Lib.Thread)

local e = Roact.createElement

local Board = require(script.Parent.Board.BoardContainer)
local ChessBoard = require(Knit.Shared.Classes.ChessBoard)
local AppStore = require(Knit.Client.State.AppStore)
local BoardGuiStore = require(Knit.Client.State.BoardGuiStore)
local BoardGuiActions = require(Knit.Client.State.BoardGuiStore.BoardGuiActions)

local Constants = require(Knit.Shared.Constants)
local Themes = require(script.Parent.Parent.Themes)

local chessBoard = ChessBoard.new(Constants.Layouts.Start)

return function(target) 
    local boardGuiStore = BoardGuiStore.new()

    local ui = Roact.mount(
        e(Board, {
            ["Board"] = chessBoard.Board,
            ["BoardGuiStore"] = boardGuiStore,
        }), 
        target
    )

    wait(3)

    boardGuiStore:dispatch(BoardGuiActions.createFlipBoard({
        ["IsFlipped"] = true,
    }))
    return function()
        Roact.unmount(ui)
        boardGuiStore:destruct()
    end
end
