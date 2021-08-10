--Must not require BoardReducers!
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Lib.Rodux)

local BoardGuiActions = {}

function BoardGuiActions.createFlipBoard(config)
    return {
        ["type"] = "FlipBoard",
        ["target"] = config.IsFlipped,
    }
end

function BoardGuiActions.createSetPieceVisibility(config)
    return {
        ["type"] = "SetPieceVisibility",
        ["position"] = config.Position,
        ["newState"] = config.IsVisible,
    }
end

function BoardGuiActions.createAssignBoardTheme(config)
    return {
        ["type"] = "AssignBoardTheme",
        ["target"] = config.TargetTheme,
    }
end
return BoardGuiActions