--[[
    UIClass
    UnknownParabellum
    Created on March 25, 2021 
]]
local Players = game:GetService("Players")
local Maid 

local UIClass = {}
UIClass.__index = UIClass


function UIClass:GetScreenUI(name)
    return self.Player.PlayerGui:FindFirstChild(name)
end

function UIClass:Load()
    if not self.Loaded then
        self.Loaded = true        
    end
end

function UIClass:UnLoad()
    if self.Loaded then
		self.Loaded = false 
		self._maid:DoCleaning()
    end
end
 
function UIClass.new()
	local self = setmetatable({
		["Name"] = "BaseClass",
		["Player"] = Players.LocalPlayer,
		["Loaded"] = false,
        ["_maid"] = Maid.new(),        
    },UIClass)
    return self
end

function UIClass:Destroy()
	self:UnLoad()
end

function UIClass:Init(framework)
	Maid = framework.Shared.Utils.Maid
end

return UIClass