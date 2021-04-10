--Must not require BoardReducers!
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Utils.Rodux)

local BoardActions = {}

function BoardActions.createMove(orig,target)
    return {
        ["type"] = "Move",
        ["orig"] = orig,
        ["target"] = target
    }
end

function BoardActions.createDestroy(target)
    return {
        ["type"] = "Destroy",
        ["target"] = target
    }
end

function BoardActions.createCreate(pieceType,target)
    return {
        ["type"] = "Destroy",
        ["pieceType"] = pieceType,
        ["target"] = target,
    }
end

return BoardActions