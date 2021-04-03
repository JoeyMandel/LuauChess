-- Rook
-- UnknownParabellum
-- February 27, 2021

--[[
	
	local Rook = Knight.new()
	

--]]

local BasePiece = require(script.Parent)

local Rook = setmetatable({},BasePiece)
Rook.__index = Rook

function Rook.new(base)	
	local self = setmetatable(base,Rook)
	self.Type = "Rook"
	self:AddTag("Rook")
	self:AddComponent("Castling")
	self:AddComponent("TwoAxisMovement")
	return self
end


return Rook