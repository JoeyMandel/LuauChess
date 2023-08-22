local MapClass = require(script.Parent.Parent.MapClass)
local ChessConstants = require(script.Parent.Parent.ChessConstants)

local PIECES_CONSTS = ChessConstants.PIECES

local Pawn = {}

local function findPseudoLegalMoves(piecePosition, boardState)
    local piecesPositionsMap = boardState.PiecesMap
    local enPassentTargetPosition = boardState.EnPassentTargetPosition

    local legalMoveMap = MapClass.new()

    local xPiecePosition, yPiecePosition = piecesPositionsMap.IndexToPos(piecePosition)
    local isWhite = piecesPositionsMap:GetValueAt(piecePosition) == PIECES_CONSTS.W_PAWN

    

end

function Pawn.GetPieceBehavior(piecePosition, boardState)
    local pseudoLegalMoves = findPseudoLegalMoves(boardState)

end

return Pawn
