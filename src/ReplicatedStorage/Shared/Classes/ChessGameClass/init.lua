--[[

UnknownParabellum
8/19/2023
ChessGameClass:
    Acts as a simple front-end interface to internal chess game logic

]]

local BoardLoader = require(script.BoardLoader)

local ChessGameClass = {}
ChessGameClass.__index = ChessGameClass

function ChessGameClass.new()
    local self = setmetatable({
        ["BoardState"] = nil,
        ["PseudoLegalMovesMap"] = nil,
        ["MoveMasksMap"] = nil,
    }, ChessGameClass)

    return self
end

function ChessGameClass:Play(startingPositionFEN)
    local boardState = BoardLoader.CreateBoardStatus(startingPositionFEN)
    print(boardState.PiecesMap)
    self:UpdateGame(boardState)

end

function ChessGameClass:UpdateGame(boardState)
    self.BoardState = boardState
end

function ChessGameClass:Stop()
    
end

function ChessGameClass:MakeMove()
    
end

--[[
    EXAMPLE FEN STRING:
    rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
]]

return ChessGameClass
