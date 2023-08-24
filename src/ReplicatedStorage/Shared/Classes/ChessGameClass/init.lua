--[[

UnknownParabellum
8/19/2023
ChessGameClass:
    Acts as a simple front-end interface to internal chess game logic

]]

local BoardLoader = require(script.BoardLoader)
local PieceBehaviors = require(script.PieceBehaviors)

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
    self:UpdateGame(boardState)
end

function ChessGameClass:UpdateGame(boardState)
    local piecePositionsMap = boardState.PiecesMap
    self.BoardState = boardState
    
    piecePositionsMap:Visualize()

    for position = 0, 63 do
        local pieceType = piecePositionsMap:GetValueAt(position)
        local pieceBehavior = PieceBehaviors:GetBehaviorFor(pieceType)

        if pieceBehavior == nil then
            continue
        end
        pieceBehavior.GetPieceBehavior(position, boardState)
    end
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
