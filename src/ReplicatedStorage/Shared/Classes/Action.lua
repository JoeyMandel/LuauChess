-- Action
-- UnknownParabellum
-- April 1, 2021

--[[
	
	local action = Action.new()
	

--]]



local Action = {}
Action.__index = Action
--[[
 This is what a new action call looks like: Action.new("Move",13,15,"Destroy",13,"Create",15,"Rook")
 Here what it returns:
 	{
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
local validActions = {
	["Move"] = {},
	["Destroy"] = {},
	["Create"] = {},
}
function validActions.Move:AssignValue(val)
	if not self.Orig then
		self.Orig = val
	else
		self.Target = val
	end
end

function validActions.Destroy:AssignValue(val)
	self.Target = val
end

function validActions.Create:AssignValue(val)
	if not self.Target then
		self.Target = val
	else
		self.PieceType = val
	end
end

function Action.new(...)
	local actionInfo = {...}
	local processedActions = {}
	for iter,val in pairs(actionInfo) do
		local valType = typeof(val)
		if valType == "string" and validActions[val] then
			table.insert(processedActions,{["Type"] = val})
		elseif  valType == "number" then
			local lastAction = processedActions[#processedActions]
			lastAction:AssignValue(val)
		end
	end
end

return Action