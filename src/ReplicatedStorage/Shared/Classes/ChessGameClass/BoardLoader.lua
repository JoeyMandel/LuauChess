--[[
UnknownParabellum
8/19/2023
BoardLoader:
    Loads all key information from a FENString into an easy to use format
]]

local MapClass = require(script.Parent.MapClass)
local ChessConstants = require(script.Parent.ChessConstants)

local PIECES_CONSTS = ChessConstants.PIECES

type BoardState = {
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

local function reverseArray(tbl)
	local itemCount = #tbl
	local reversedArray = table.create(itemCount)
	for index = 1,itemCount do
		reversedArray[index] = tbl[itemCount - index + 1]
	end
	return reversedArray
end

local BoardLoader = {}

local function createPiecesMap(piecePositionsField)
    local piecesMap = MapClass.new()
    local ranks = reverseArray(piecePositionsField:split("/"))

    for index, piecePositions in pairs(ranks) do
        local currentRank = index - 1
        local currentFile = 0
        
        for letterIndex = 1, piecePositions:len() do
            local pieceLetter = piecePositions:sub(letterIndex, letterIndex)
            local pieceEnum = letterToPiece[pieceLetter]

            local numberOfEmptySpaces = tonumber(pieceLetter)
            local isLetterEmptySpaceCount = typeof(numberOfEmptySpaces) == "number"

            local pieceIndex = piecesMap.PosToIndex(currentFile, currentRank)

            if isLetterEmptySpaceCount then
                currentFile += numberOfEmptySpaces
                continue
            end

            piecesMap:SetValueAt(pieceIndex, pieceEnum)
            currentFile += 1
        end
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

--[=[
    Converts a FEN string into an easy to read format in our scripts

    Starting Position as a FEN String:
    ```
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
    ```
]=]
function BoardLoader.CreateBoardState(fenString): BoardState
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