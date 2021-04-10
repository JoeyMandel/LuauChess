-- Bishop
-- UnknownParabellum
-- February 27, 2021

--[[
	
	local Bishop = Knight.new()
	

--]]

local BasePiece = require(script.Parent)

local Bishop = setmetatable({},BasePiece)
Bishop.__index = Bishop

function Bishop.new(base)	
	local self = setmetatable(base,Bishop)
	self.Type = "Bishop"
	self:AddTag("Bishop")
	self:AddComponent("DiagonalMovement")
	return self
end


return Bishop