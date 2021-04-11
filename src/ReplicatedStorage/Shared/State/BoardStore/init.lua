local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Utils.Rodux)

local Reducers = require(script.BoardReducers)

local reducer = Rodux.createReducer(nil,Reducers)

local BoardStore = {}

function BoardStore.new(initState)
    return Rodux.Store.new(reducer,initState)
end

return BoardStore