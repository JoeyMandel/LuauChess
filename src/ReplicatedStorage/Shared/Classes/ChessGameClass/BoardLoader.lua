--[[
UnknownParabellum
8/19/2023
BoardLoader:
    Loads all key information from a FENString into an easy to use format

]]

local MapClass = require(script.Parent.MapClass)
local ChessConstants = require(script.Parent.ChessConstants)

local PIECES_CONSTS = ChessConstants.PIECES

local letterToPiece = {
    ["p"] = PIECES_CONSTS.B_PAWN,
    ["r"] = PIECES_CONSTS.B_ROOK,
    ["b"] = PIECES_CONSTS.B_BISHOP,
    ["n"] = PIECES_CONSTS.B_KNIGHT,
    ["q"] = PIECES_CONSTS.B_QUEEN,
    ["k"] = PIECES_CONSTS.B_KING,

    ["P"] = PIECES_CONSTS.W_PAWN,
    ["R"] = PIECES_CONSTS.W_ROOK,
    ["B"] = PIECES_CONSTS.W_BISHOP,
    ["N"] = PIECES_CONSTS.W_KNIGHT,
    ["Q"] = PIECES_CONSTS.W_QUEEN,
    ["K"] = PIECES_CONSTS.W_KING
}

local BoardLoader = {}

local function createPiecesMap(piecePositionsField)
    local piecesMap = MapClass.new()

    local currentPosition = 0
    for letterIndex = 1, piecePositionsField.len() do
        local pieceLetter = piecePositionsField:sub(letterIndex, letterIndex)
        local pieceEnum = letterToPiece[pieceLetter]

        local isLetterDivider = pieceLetter == "/"

        local numberOfEmptySpaces = tonumber(pieceLetter)
        local isLetterEmptySpaceCount = typeof(numberOfEmptySpaces) == "number"

        if isLetterEmptySpaceCount then
            currentPosition += numberOfEmptySpaces
            continue
        elseif isLetterDivider then
            continue
        end

        piecesMap:SetValueAt(currentPosition, pieceEnum)
        currentPosition += 1
    end
end

local function getCastlingRights(castlingRightsField)    
    local castlingRights = {
        [PIECES_CONSTS.B_KING] = false,
        [PIECES_CONSTS.B_QUEEN] = false,

        [PIECES_CONSTS.W_KING] = false,
        [PIECES_CONSTS.W_QUEEN] = false,
    }
    
    local isFieldEmpty = castlingRightsField == "-"

    for letterIndex = 1, castlingRightsField.len() do
        if isFieldEmpty then
            continue
        end

        local castlingSideLetter = castlingRightsField:sub(letterIndex, letterIndex)
        local castlingSideEnum = letterToPiece[castlingSideLetter]

        castlingRights[castlingSideEnum] = true
    end

    return castlingRights
end

local function getEnPassentTarget(enPassentTargetField)
    
end
--[[
    rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
]]

function BoardLoader.CreateBoardFromFEN(fenString)
    local fields = fenString:split(" ")
    local piecePositionsField = fields[1]
    local playerToMoveField = fields[2]
    local castlingRightsField = fields[3]

    local piecesMap = createPiecesMap(piecePositionsField)
    local isWhiteToMove = playerToMoveField == "w"
    local castlingRights = getCastlingRights(castlingRightsField)
    
end

return BoardLoader