local MapClass = require(script.Parent.Parent.MapClass)
local ChessConstants = require(script.Parent.Parent.ChessConstants)

local PIECES_CONSTS = ChessConstants.PIECES

local W_PAWN = PIECES_CONSTS.W_PAWN
local B_PAWN = PIECES_CONSTS.B_PAWN

local Pawn = {}

local function findPseudoLegalMoves(piecePosition, boardState)
    local piecesPositionsMap = boardState.PiecesMap
    local enPassentTargetPosition = boardState.EnPassentTargetPosition
    local _, yPiecePosition = piecesPositionsMap.IndexToPos(piecePosition)

    local legalMoveMap = MapClass.new()

    local isWhite = piecesPositionsMap:GetValueAt(piecePosition) == W_PAWN
    local yDirection = isWhite and 1 or -1
    
    local function addDiagonalMoves()
        for xDirection = -1, 1, 2 do
            local diagonalPosition = piecePosition + (8 * yDirection) + xDirection 
            local targetPiece = piecesPositionsMap:GetValueAt(diagonalPosition)
            
            local isTargetEnPassentSquare = diagonalPosition == enPassentTargetPosition
            local isInMapRange = diagonalPosition >= 0 and diagonalPosition <= 63
            
            local isPieceAtTarget = typeof(targetPiece) == "number"

            if isTargetEnPassentSquare and isInMapRange then
                legalMoveMap:SetValueAt(diagonalPosition, true)
            elseif isPieceAtTarget then
                local isTargetWhite = PIECES_CONSTS:IsPieceWhite(targetPiece)
    
                if isWhite ~= isTargetWhite then
                    legalMoveMap:SetValueAt(diagonalPosition, true)
                end
            end
        end
    end

    local function addForwardMoves()
        local forwardPosition = piecePosition + (8 * yDirection)
        local forwardPiece = piecesPositionsMap:GetValueAt(forwardPosition)

        local canPawnSkipSquare = isWhite and yPiecePosition == 1 or yPiecePosition == 6
        local isForwardBlocked = typeof(forwardPiece) == "number"

        if isForwardBlocked then
            return
        end

        legalMoveMap:SetValueAt(forwardPosition, true)

        if canPawnSkipSquare then
            local skipPosition = piecePosition + (16 * yDirection)
            local skipPiece = piecesPositionsMap:GetValueAt(skipPosition)

            local isSkipBlocked = typeof(skipPiece) == "number"

            if isSkipBlocked then
                return
            end

            legalMoveMap:SetValueAt(skipPosition, true)
        end
    end

    addDiagonalMoves()
    addForwardMoves()

    return legalMoveMap
end

function Pawn.GetPieceBehavior(piecePosition, boardState)
    local pseudoLegalMoves = findPseudoLegalMoves(piecePosition, boardState)
end

function Pawn.IsBehaviorUsedBy(pieceType)
    if pieceType == W_PAWN or pieceType == B_PAWN then
        return true
    end
    return false
end

return Pawn
