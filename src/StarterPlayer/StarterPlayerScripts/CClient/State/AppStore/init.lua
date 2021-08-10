local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Lib.Rodux)

local Themes = require(Knit.Client.Controllers.UIController.Themes)

local reducers = require(script.AppReducers)
local reducer = Rodux.createReducer(nil,reducers)

local AppStore = {}

function AppStore.new()
	local initState = {
		["AppTheme"] = Themes.AppThemes.Dark,
	}

    return Rodux.Store.new(reducer,initState)
end

return AppStore