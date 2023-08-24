local PieceBehaviors = {
    ["Behaviors"] = {}
}

function PieceBehaviors:GetBehaviorFor(pieceType)
    for _, behavior in pairs(self.Behaviors) do
        if behavior.IsBehaviorUsedBy(pieceType) then
            return behavior
        end
    end
    return nil
end

for _, module in pairs(script:GetChildren()) do
    table.insert(PieceBehaviors.Behaviors, require(module))
end

return PieceBehaviors