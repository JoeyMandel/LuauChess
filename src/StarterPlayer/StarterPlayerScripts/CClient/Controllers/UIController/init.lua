--[[
	UIController
	UnknownParabellum
    Created on March 26, 2021 
]]


local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Constants 

local UIController = Knit.CreateController { Name = "UIController" }
UIController.UIs = {}

function UIController:KnitStart()
	if not _G.GuiLoaded then
		warn("Waiting for UI to load...")
	   _G.Loaded:Wait()
	   warn("UI Objects Fully Loaded!")
	end
	require(script.BaseClass):Init(self)
	for _, mod in pairs(script:GetChildren()) do
		local name = mod.Name
		self.UIs[name] = require(mod)
		self.UIs[name]:Init(self)
	end
	local board = require(Knit.Shared.Classes.ChessBoard).new("8/8/4k3/8/4K3/2RN2Q1/8/8 w - - 0 1")
	
	self.UIs.Timers:SetConfig(board)
	self.UIs.Board:SetBoard(board)
	self.UIs.Board:Display("Ocean Blue","Neo",true)
	self.UIs.Board:Activate()
	
	self.UIs.Timers:StartCounting(nil,false)
end


function UIController:KnitInit()
	Constants = require(Knit.Shared.Constants)
end


return UIController