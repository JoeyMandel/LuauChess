local Knit = require(game:GetService("ReplicatedStorage").Knit)



local UIController = Knit.CreateController({
    ["Name"] = "init",
    ["Client"] = {},
})

function UIController:KnitStart()
    wait(3)
    local Roact = require(Knit.Client.Lib.Roact)
    
    local e = Roact.createElement
    
    local Board = require(script.Components.Board.BoardContainer)
    local ChessBoard = require(Knit.Shared.Classes.ChessBoard)
    local AppStore = require(Knit.Client.State.AppStore)
    local BoardGuiStore = require(Knit.Client.State.BoardGuiStore)
    local BoardGuiActions = require(Knit.Client.State.BoardGuiStore.BoardGuiActions)
    local Themes = require(script.Themes)
    local chessBoard = ChessBoard.new()

    local ui = Roact.mount(
        e(Board, {
            ["Board"] = chessBoard.Board,
            ["AppStore"] = AppStore.new(),
            ["BoardGuiStore"] = BoardGuiStore.new(),
        })
    )
end


function UIController:KnitInit()
    
end


return UIController