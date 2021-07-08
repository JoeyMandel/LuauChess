-- Tile
-- UnknownParabellum
-- February 18, 2021

--[[
	
	local tile = Tile.new()
	

--]]

local numToFile = {"a","b","c","d","e","f","g","h"}

local Tile = {}
Tile.__index = Tile


function Tile.new(position)
	
	local self = setmetatable({
		["Class"] = "Tile",
		["Position"] = position,
		["File"] = numToFile[position.X],
		["Rank"] = position.Y,
		["IsDark"] = false,
		["Piece"] = nil,
	}, Tile)
	return self
	
end


return Tile