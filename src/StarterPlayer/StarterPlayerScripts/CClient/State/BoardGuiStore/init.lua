local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Lib.Rodux)

local Themes = require(Knit.Client.Controllers.UIController.Themes)

local reducers = require(script.BoardGuiReducers)
local reducer = Rodux.createReducer(nil,reducers)

local BoardGuiStore = {}

function BoardGuiStore.new()
	local initState = {
		["BoardTheme"] = Themes.BoardThemes["Ocean Blue"],
		["PieceTheme"] = Themes.PieceThemes.Default,
		["InvisiblePieces"] = {},
		["IsFlipped"] = false,
	}

    return Rodux.Store.new(reducer,initState)
end

return BoardGuiStore