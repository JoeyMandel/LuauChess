local Knit = require(game:GetService("ReplicatedStorage").Knit)

local BoardGuiReducers = {}

local function shallowCopyState(oldState)
    local newState = {}

    for index,val in pairs(oldState) do
        newState[index] = val
    end
    return newState
end

function BoardGuiReducers.FlipBoard(state, action)
    local newState = shallowCopyState(state)
    newState.IsFlipped = action.target

    return newState
end

function BoardGuiReducers.SetPieceVisibility(state, action)
    local newState = shallowCopyState(state)

    newState.InvisiblePieces[action.position] = action.newState
    return newState
end

function BoardGuiReducers.AssignBoardTheme(state, action)
    local newState = shallowCopyState(state)
    newState.BoardTheme = action.target

    return newState
end

return BoardGuiReducers