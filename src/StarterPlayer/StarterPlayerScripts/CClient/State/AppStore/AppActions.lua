--Must not require BoardReducers!
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Lib.Rodux)

local AppActions = {}

function AppActions.createAssignAppTheme(config)
    return {
        ["type"] = "AssignAppTheme",
        ["target"] = config.TargetTheme,
    }
end

return AppActions