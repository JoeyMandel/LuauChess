--[[
UnknownParabellum
8/19/2023
BoardLoader:
    Loads all key information from a FENString into an easy to use format
]]

local MapClass = require(script.Parent.MapClass)
local ChessConstants = require(script.Parent.ChessConstants)

local PIECES_CONSTS = ChessConstants.PIECES

type BoardStatus = {
    ["PiecesMap"] : table,
    ["IsWhiteToMove"] : boolean,
    ["CastlingRights"] : table,
    ["EnPassentTargetPosition"] : number,
    ["FiftyMoveRuleCounter"] : number,
    ["FullMoveCount"] : number
}

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
    for letterIndex = 1, piecePositionsField:len() do
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

    return piecesMap
end

local function getCastlingRights(castlingRightsField)    
    local castlingRights = {
        [PIECES_CONSTS.B_KING] = false,
        [PIECES_CONSTS.B_QUEEN] = false,

        [PIECES_CONSTS.W_KING] = false,
        [PIECES_CONSTS.W_QUEEN] = false,
    }
    
    local isFieldEmpty = castlingRightsField == "-"

    for letterIndex = 1, castlingRightsField:len() do
        if isFieldEmpty then
            continue
        end

        local castlingSideLetter = castlingRightsField:sub(letterIndex, letterIndex)
        local castlingSideEnum = letterToPiece[castlingSideLetter]

        castlingRights[castlingSideEnum] = true
    end

    return castlingRights
end

local function getEnPassentTarget(enPassentTargetField, boardMap)
    if enPassentTargetField == "-" then
        return -1
    end

    local fileLetter = enPassentTargetField:sub(1, 1)
    local rankLetter = enPassentTargetField:sub(2, 2)

    local firstFileLetterCode = string.byte("a")

    local xPosition = string.byte(fileLetter) - firstFileLetterCode
    local yPosition = tonumber(rankLetter) - 1

    local position = boardMap.PosToIndex(xPosition, yPosition)

    return position
end

local function getFiftyMoveRuleStatus(halfMoveField)
    return tonumber(halfMoveField) or 0
end

local function getFullMoveCount(moveCountField)
    return tonumber(moveCountField) or 1
end

--[[
    rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
]]

function BoardLoader.CreateBoardStatus(fenString): BoardStatus
    local fields = fenString:split(" ")
    local piecePositionsField = fields[1]
    local playerToMoveField = fields[2]
    local castlingRightsField = fields[3]
    local enPassentTargetField = fields[4]
    local fiftyMoveRuleField = fields[5]
    local fullMoveCountField = fields[6]

    local piecesMap = createPiecesMap(piecePositionsField)
    local isWhiteToMove = playerToMoveField == "w"
    local castlingRights = getCastlingRights(castlingRightsField)
    local enPassentPosition = getEnPassentTarget(enPassentTargetField, piecesMap)
    local fiftyMoveRuleCounter = getFiftyMoveRuleStatus(fiftyMoveRuleField)
    local fullMoveCount = getFullMoveCount(fullMoveCountField)

    return {
        ["PiecesMap"] = piecesMap,
        ["IsWhiteToMove"] = isWhiteToMove,
        ["CastlingRights"] = castlingRights,
        ["EnPassentTargetPosition"] = enPassentPosition,
        ["FiftyMoveRuleCounter"] = fiftyMoveRuleCounter,
        ["FullMoveCount"] = fullMoveCount
    }
end

return BoardLoader