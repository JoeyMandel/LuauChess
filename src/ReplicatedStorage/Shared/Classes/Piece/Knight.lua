-- Knight
-- UnknownParabellum
-- February 27, 2021

--[[
	
	local Knight = Knight.new()
	

--]]

local BasePiece = require(script.Parent)

local Knight = setmetatable({},BasePiece)
Knight.__index = Knight

function Knight.new(base)	
	local self = setmetatable(base,Knight)
	self.Type = "Knight"

	self:AddTag("Knight")
	self:AddComponent("KnightMovement")
	return self
end


return Knight