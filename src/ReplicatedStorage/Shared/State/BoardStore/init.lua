local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Rodux = require(Knit.Shared.Lib.Rodux)

local Tile = require(Knit.Shared.Classes.Tile)

local BoardUtil = require(Knit.Shared.Lib.BoardUtil)

local Reducers = require(script.BoardReducers)

local reducer = Rodux.createReducer(nil,Reducers)

local BoardStore = {}

function BoardStore.new(initState)
    for file = 1,8 do --// Set up board 
		local isBlack = (file%2 ~= 0)
		for rank = 1,8 do
			local tile = Tile.new(Vector2.new(file,rank))
			tile.IsDark = isBlack
			BoardUtil.Set(initState,tile.Position,tile)

			isBlack = not isBlack
		end
	end	

    return Rodux.Store.new(reducer,initState)
end

return BoardStore