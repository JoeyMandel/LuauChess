-- Action
-- UnknownParabellum
-- April 1, 2021

--[[
	
	local action = Action.new()
	

--]]



local Action = {}
Action.__index = Action


function Action.new(...)
	local actionInfo = {...}
	
	--[[
	sample action:
		[1] = {
			Type = "Move"
			Orig = Position
			Target = Position
		}
		[2] = {
			Type = "Destroy"
			Target = Position
		}
		[3] = {
			Type = "Create"
			Target = Position
			PieceType = "Queen"
		}
	]]
	return {
		
	}
end


return Action