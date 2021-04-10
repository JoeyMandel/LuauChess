-- Tag System
-- UnknownParabellum
-- March 6, 2021

--[[
	

--]]



local TagSystem = {}

function TagSystem.Include(tbl)
	tbl.Tags = {}

	function tbl:RemoveTag(name)
		self.Tags[name] = nil
	end

	function tbl:AddTag(name)
		self.Tags[name] = true
	end

	function tbl:HasTag(name)
		return (self.Tags[name] ~= nil)
	end
end

return TagSystem