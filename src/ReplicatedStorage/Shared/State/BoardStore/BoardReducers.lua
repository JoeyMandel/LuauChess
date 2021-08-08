-- Note this module requires BoardActions first so BoardActions must not require BoardReducers when it starts
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Piece = require(Knit.Shared.Classes.Piece)
local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local Rodux = require(Knit.Shared.Lib.Rodux)
local BoardActions = require(script.Parent.BoardActions)

local ReducerFuncs = {}

local v2ToInt = BoardUtil.Vector2ToInt

local function shallowCopyState(oldState)
    local newState = {}

    for index,val in pairs(oldState) do
        newState[index] = val
    end
    return newState
end


function ReducerFuncs.Move(state, action)
    local newState = shallowCopyState(state)

    local orig = v2ToInt(action.orig)
    local target = v2ToInt(action.target)

    local origTile = newState[orig]
    local targetTile = newState[target]

    local origPiece = origTile.Piece
    local targetPiece = targetTile.Piece
    
    if targetPiece then
        newState = ReducerFuncs.Destroy(newState,BoardActions.createDestroy(target))
    end

    origTile.Piece = nil
    targetTile.Piece = origPiece

    table.insert(newState.ActionHistory, action)
    return newState
end

function ReducerFuncs.Destroy(state, action)
    local newState = shallowCopyState(state)

    local boardObject = newState.Board

    local target = v2ToInt(action.target)
    local targetTile  = newState[target]

    
    table.remove(boardObject.Pieces, BoardUtil.GetPieceIndexFromArray(boardObject.Pieces, targetTile.Piece))

    local colorPieces = boardObject[BoardUtil.GetColor(Piece.IsBlack)].Pieces
    table.remove(colorPieces, BoardUtil.GetPieceIndexFromArray(colorPieces, targetTile.Piece))

    targetTile.Piece:Destroy()
    targetTile.Piece = nil

    table.insert(newState.ActionHistory, action)
    return newState
end

function ReducerFuncs.Create(state, action)
    local newState = shallowCopyState(state)
    
    local boardObject = newState.Board
    local target = action.target
    local targetTile  = newState[v2ToInt(target)]

    local newPiece = Piece.new({
        ["Type"] = action.pieceType,
        ["Position"] = target,
        ["Board"] = boardObject,
        ["Color"] = action.isBlack,
    })

    targetTile.Piece = newPiece

    table.insert(boardObject.Pieces, newPiece)
    table.insert(boardObject:GetColorState(action.isBlack).Pieces, newPiece)

    table.insert(newState.ActionHistory, action)
    return newState
end

return ReducerFuncs