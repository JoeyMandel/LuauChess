--[[
	UIController
	UnknownParabellum
    Created on March 26, 2021 
]]


local Knit = require(game:GetService("ReplicatedStorage").Knit)
local UIController = Knit.CreateController { Name = "UIController" }
UIController.UIs = {}


local function cubicBezierCurve(t,p0,p1,c1,c2)
    return (((1-t)^3)*p0) + (3*((1-t)^2)*t*p1) + (3*(1-t)*t^2*c1) + ((t^3) *c2)
end

function UIController:LerpCubicBezierCurve(time: number,startPos: Vector2,endPos: Vector2,controlPos1: Vector2,controlPos2: Vector2)
    local result = Vector2.new(cubicBezierCurve(time,startPos.X,controlPos2.X,controlPos1.X,endPos.X), cubicBezierCurve(time,startPos.Y,controlPos2.Y,controlPos1.Y,endPos.Y))
    return result
end


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
	local board = require(Knit.Shared.Classes.ChessBoard).new(require(Knit.Shared.Constants).Layouts.Start)
	
	self.UIs.Timers:SetConfig(board)
	self.UIs.Board:SetBoard(board)
	self.UIs.Board:Display("Ocean Blue","Neo",false)
	self.UIs.Board:Activate()
	
	self.UIs.Timers:StartCounting(nil,false)
end


function UIController:KnitInit()
	
end


return UIController