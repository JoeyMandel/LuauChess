--[[
    UIClass
    UnknownParabellum
    Created on March 25, 2021 
]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)
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
		self.__maid:DoCleaning()
    end
end
 
function UIClass.new()
	local self = setmetatable({
		["Name"] = "BaseClass",
		["Player"] = Players.LocalPlayer,
		["Loaded"] = false,
        ["__maid"] = Maid.new(),        
    },UIClass)
    return self
end

function UIClass:Destroy()
	self:UnLoad()
end

function UIClass:Init()
	Maid = require(Knit.Shared.Lib.Maid)
end

return UIClass