local RunService = game:GetService("RunService")
if RunService:IsStudio() then
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