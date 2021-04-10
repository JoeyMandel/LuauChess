-- King
-- UnknownParabellum
-- February 27, 2021

--[[
	
	local King = King.new()
	

--]]

local BasePiece = require(script.Parent)

local King = setmetatable({},BasePiece)
King.__index = King

function King.new(base)	
	local self = setmetatable(base,King)
	self.Type = "King"
	self:AddTag("King")
	self:AddComponent("Castling")
	self:AddComponent("KingMovement")

	return self
end


return King