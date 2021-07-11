-- Timer
-- UnknownParabellum
-- March 13, 2021

--[[
	
	local timer = Timer.new()
	

--]]
local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Thread = require(Knit.Shared.Lib.Thread)
local Maid = require(Knit.Shared.Lib.Maid)
local Signal = require(Knit.Shared.Lib.Signal)

local StatusHierarchy = {
	["Active"] = 1,
	["Inactive"] = 1,
	["Paused"] = 1,
	["Dead"] = 2,
}

local Timer = {}
Timer.__index = Timer

function Timer.ToString(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00.0";
	else
		local hours = string.format("%02.f", math.floor(seconds/3600));
		local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
		local dec = tostring(math.floor((seconds-math.floor(seconds))*10));
		return mins..":"..secs.."."..dec
	end
end

function Timer:Start(precision)
	if self:SetStatus("Active") then
		self.StartTime = self.StartTime or tick()
		self.__maid["Thread"] = Thread.DelayRepeat((precision or 0.1),function()
			self.ElapsedTime = (tick() - self.StartTime) - self.Offset
			self.OnTick:Fire(self.ElapsedTime)
			if self.ElapsedTime >= self.Length then
				self:Destroy()
			end
		end)
	end
end

function Timer:AddTime(offsetLen)
	self.Length += offsetLen
end

function Timer:Pause()
	if self:SetStatus("Paused") then
		self.__maid["Thread"] = nil
		self.PauseTime = tick()
	end
end

function Timer:UnPause()
	self.Offset += tick() - self.PauseTime
	self:Start()
end

function Timer:SetStatus(newStatus)
	local currentVal = StatusHierarchy[self.Status]
	local newStatusVal = StatusHierarchy[newStatus]
	
	if newStatusVal then
		if newStatusVal >= currentVal then
			self.Status = newStatus
			return true
		end
	end
	return false
end

function Timer.new(length)
	
	local self = setmetatable({
		["StartTime"] = nil,
		["ElapsedTime"] = 0,
		["Offset"] = 0,
		["Length"] = length or 60,
		["PauseTime"] = nil,
		
		["Status"] = "Inactive",
		["OnTick"] = Signal.new(),
		["OnEnd"] = Signal.new(),
		["__maid"] = Maid.new()
	}, Timer)
	
	self.__maid["OnTick"] = self.OnTick
	self.__maid["OnEnd"] = self.OnEnd
	
	return self
end

function Timer:Destroy()
	self.OnEnd:Fire()
	self.__maid:DoCleaning()
end

return Timer