-- Note this module requires BoardActions first so BoardActions must not require BoardReducers when it starts
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local ReducerFuncs = {}

local function shallowCopyState(oldState)
    local newState = {}

    for index,val in pairs(oldState) do
        newState[index] = val
    end
    return newState
end

function ReducerFuncs.AssignAppTheme(state, action)
    local newState = shallowCopyState(state)
    newState.AppTheme = action.target

    return newState
end

return ReducerFuncs