-- Piece Components
-- UnknownParabellum
-- February 19, 2021

--[[
	

--]]



local PieceComponents = {}

function PieceComponents.new(name,piece,config)
	local component = require(script[name])
	if component.Init then
		component:Init(PieceComponents)
	end
	return component.new(piece,config)
end

function PieceComponents:Init()
	
end

return PieceComponents