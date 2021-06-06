-- Base Component
-- UnknownParabellum
-- February 26, 2021

--[[
	
	local baseComponent = BaseComponent.new()
	

--]]

local BaseComponent = {}
BaseComponent.__index = BaseComponent


function BaseComponent.new(piece)
	local framework = require(script.Parent)
	local self = setmetatable({
		["Piece"] = piece,
		["Board"] = piece:Get("Board"),
		["Position"] = piece.Position,
		["__maid"] = framework.Shared.Lib.Maid.new()
	}, BaseComponent)
	framework.Shared.TagSystem.Include(self)
	
	return self
end

function BaseComponent:Destroy()
	self.__maid:DoCleaning()
end

return BaseComponent