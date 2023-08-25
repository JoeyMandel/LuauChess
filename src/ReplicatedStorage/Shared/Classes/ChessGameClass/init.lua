--[[

UnknownParabellum
8/19/2023
ChessGameClass:
    Acts as a front-end interface to internal chess game logic

]]

local MapClass = require(script.MapClass)
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
    local boardState = BoardLoader.CreateBoardState(startingPositionFEN)
    self:UpdateGameState(boardState)
end

function ChessGameClass:UpdateGameState(boardState)
    local piecePositionsMap = boardState.PiecesMap
    local emptyMoveMaskMap = MapClass.new(true)

    self.BoardState = boardState
    self.PseudoLegalMovesMap = MapClass.new()
    self.MoveMasksMap = MapClass.new(emptyMoveMaskMap)

    piecePositionsMap:Visualize()

    local function updatePiece(piecePosition, piece)
        local pieceBehavior = PieceBehaviors:GetBehaviorFor(piece)

        if pieceBehavior == nil then
            return
        end

        local behavior = pieceBehavior.CreateBehavior(piecePosition, boardState)
        local pseudoLegalMoveMap = behavior.PseudoLegalMoves
        local moveMaskedPieces = behavior.MoveMasks

        -- apply move masks to pieces
        -- update pseudo legal moves

        self.PseudoLegalMovesMap:SetValueAt(piecePosition, pseudoLegalMoveMap)

        for _, restrictedPiece in pairs(moveMaskedPieces) do
            local position = restrictedPiece.Position
            local moveMask = restrictedPiece.MoveMask
        end
    end

    for position = 0, 63 do
        local piece = piecePositionsMap:GetValueAt(position)
        local pieceExists = typeof(piece) == "number"

        if not pieceExists then
            continue
        end

        updatePiece(position, piece)
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
