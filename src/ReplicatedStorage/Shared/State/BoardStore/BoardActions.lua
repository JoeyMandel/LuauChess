--Must not require BoardReducers!
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Lib.Rodux)

local BoardActions = {}

function BoardActions.createMove(config)
    return {
        ["type"] = "Move",
        ["orig"] = config.Orig,
        ["target"] = config.Target
    }
end

function BoardActions.createDestroy(config)
    return {
        ["type"] = "Destroy",
        ["target"] = config.Target
    }
end

function BoardActions.createCreate(config)
    return {
        ["type"] = "Create",
        ["target"] = config.Target,
        ["pieceType"] = config.Type,
        ["isBlack"] = config.IsBlack,
    }
end

return BoardActions