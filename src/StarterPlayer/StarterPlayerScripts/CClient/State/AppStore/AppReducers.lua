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

end

function ReducerFuncs.AssignBoardTheme(state, action)

end

return ReducerFuncs