local RunService = game:GetService("RunService")
if RunService:IsClient() and RunService:IsServer() then -- Must really be in studio
	return {
		["Server"] = game:GetService("ServerScriptService").CServer,
		["Shared"] = game:GetService("ReplicatedStorage").Shared,
		["Client"] = game:GetService("StarterPlayer").StarterPlayerScripts.CClient,
	}
elseif RunService:IsServer() then
	return require(script.KnitServer)
elseif RunService:IsClient() then
	script.KnitServer:Destroy()
	return require(script.KnitClient)
end