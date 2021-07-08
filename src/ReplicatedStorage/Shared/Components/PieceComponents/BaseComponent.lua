-- Base Component
-- UnknownParabellum
-- February 26, 2021

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local TagSystem = require(Knit.Shared.Classes.TagSystem)
local Maid = require(Knit.Shared.Lib.Maid)

local BaseComponent = {}
BaseComponent.__index = BaseComponent


function BaseComponent.new(piece)
	local self = setmetatable({
		["Piece"] = piece,
		["Board"] = piece.Board,
		["Position"] = piece.Position,
		["__maid"] = Maid.new(),
	}, BaseComponent)
	TagSystem.Include(self)
	
	return self
end

function BaseComponent:Destroy()
	self.__maid:DoCleaning()
end

return BaseComponent