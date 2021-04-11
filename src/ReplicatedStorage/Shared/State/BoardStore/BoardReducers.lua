-- Note this module requires BoardActions first so BoardActions must not require BoardReducers when it starts

local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Utils.Rodux)
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
    if action.type == "Create" then 
        error("Create piece is not finished yet!")
    end
end

return ReducerFuncs