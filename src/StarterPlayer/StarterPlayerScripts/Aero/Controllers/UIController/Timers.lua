-- Timers
-- Username
-- January 18, 2021
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local TimerClass
local Thread

local PlayerGui
local UI
local Templates
local RealTimers

local baseClass = require(script.Parent.BaseClass)

local Timers = setmetatable({},baseClass)
Timers.__index = Timers
local base = baseClass.new()
Timers = setmetatable(base, Timers)

function Timers:SetUpUIs()
	
end

function Timers:UpdateUI(isBlack,newTime)
	local stringTime = TimerClass.ToString(newTime)
	local currentRealTimer = isBlack and RealTimers.Black or RealTimers.White
	local lastRealTimer = isBlack and RealTimers.White or RealTimers.Black
	
	currentRealTimer.Time.BackgroundTransparency = 0	
	currentRealTimer.Time.Label.Text = stringTime
	currentRealTimer.Time.Label.TextTransparency = 0
	
	lastRealTimer.Time.BackgroundTransparency = 0.6
	lastRealTimer.Time.Label.TextTransparency = 0.6
end

function Timers:StartCounting(timeLimitation, startingIsBlack)
	timeLimitation = timeLimitation or (3 * 60)
	self.WhiteTimer = TimerClass.new(timeLimitation)
	self.BlackTimer = TimerClass.new(timeLimitation)
	self.NextIsBlack = startingIsBlack
	
	self._maid["BoardChanged"] = self.Board.AfterMoved:Connect(function()
		local currentTimer = self.NextIsBlack and self.BlackTimer or self.WhiteTimer
		local lastTimer = self.NextIsBlack and self.WhiteTimer or self.BlackTimer
		self.NextIsBlack = not self.NextIsBlack
		if lastTimer.Status ==  "Active" then
			lastTimer:Pause()
		end
		if currentTimer.Status == "Inactive" then
			currentTimer:Start()
		elseif currentTimer.Status == "Paused" then
			currentTimer:UnPause()
		end
		self._maid["OnTick"] = nil
		self._maid["OnTick"] = currentTimer.OnTick:Connect(function(timePassed)
			self:UpdateUI(self.NextIsBlack, timeLimitation - timePassed)
		end)		
	end)
end

function Timers:StopCounting()
	
end

function Timers:Load()
    if not self.Loaded then 
        self.Loaded = true
    end
end

function Timers:Unload()
    if self.Loaded then

        self.Loaded = false
    end
end

function Timers:SetConfig(board)
	self.Board = board
end
--//Basic 

function Timers:Init(framework)
	local _shared = framework.Shared
	
	TimerClass = _shared.Timer
	Thread = _shared.Utils.Thread

	PlayerGui = self.Player.PlayerGui 
	UI = PlayerGui.Game
	Templates = PlayerGui.HolderUI
	RealTimers = UI.SideBar.GameSideBar.BottomBar.Timers
end

return Timers