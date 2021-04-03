for _,v in pairs(game.StarterGui:GetChildren())do
	v.Parent = game.ReplicatedStorage.StarterGui
end

script:Destroy()