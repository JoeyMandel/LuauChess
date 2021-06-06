-- Note this module requires BoardActions first so BoardActions must not require BoardReducers when it starts
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Piece = require(Knit.Shared.Classes.Piece)

local Rodux = require(Knit.Shared.Lib.Rodux)
local BoardActions = require(script.Parent.BoardActions)

local ReducerFuncs = {}

local function shallowCopyState(oldState)
    local newState = {}

    for index,val in pairs(oldState) do
        newState[index] = val
    end
    return newState
end


function ReducerFuncs.Move(state, action)
    local newState = shallowCopyState(state)

    local orig = action.orig
    local target = action.target

    local origTile = newState[orig]
    local targetTile = newState[target]

    local origPiece = origTile.Piece
    local targetPiece = targetTile.Piece
    
    if targetPiece then
        newState = ReducerFuncs.Destroy(newState,BoardActions.createDestroy(target))
    end

    origTile.Piece = nil
    targetTile.Piece = origPiece

    return newState
end

function ReducerFuncs.Destroy(state, action)
    local newState = shallowCopyState(state)

    local target = action.target
    local targetTile  = newState[target]

    targetTile.Piece:Destroy()
    targetTile.Piece = nil

    return newState
end

function ReducerFuncs.Create(state, action)
    local newState = shallowCopyState(state)

    local target = action.target
    local targetTile  = newState[target]

    local newPiece = Piece.new({
        ["pieceType"] = action.type,
        ["Position"] = action.target,
        ["Board"] = action.board,
        ["Color"] = action.Color,
    })

    targetTile.Piece = newPiece

    return newState
end

return ReducerFuncs