-- Pawn
-- UnknownParabellum
-- February 27, 2021

--[[
	
	local pawn = Pawn.new()
	

--]]

local BasePiece = require(script.Parent)

local Pawn = setmetatable({},BasePiece)
Pawn.__index = Pawn

function Pawn.new(base)	
	local self = setmetatable(base,Pawn)
	self.Type = "Pawn"
	self:AddTag("Pawn")
	self:AddComponent("PawnMovement")
	return self
	
end


return Pawn