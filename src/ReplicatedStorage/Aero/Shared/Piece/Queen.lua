-- Queen
-- UnknownParabellum
-- February 27, 2021

--[[
	
	local Queen = Knight.new()
	

--]]

local BasePiece = require(script.Parent)

local Queen = setmetatable({},BasePiece)
Queen.__index = Queen

function Queen.new(base)	
	local self = setmetatable(base,Queen)
	self.Type = "Queen"

	self:AddTag("Queen")
	self:AddComponent("TwoAxisMovement")
	self:AddComponent("DiagonalMovement")

	return self
end


return Queen