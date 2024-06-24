local Block = {}
Block.DataName = "Block"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)

function Block.Begin(character: Model)
    character:SetAttribute("Blocking", true)
    Warp.Signal("PlayAnimation"):Fire(ReplicatedStorage.Animations.Block, {FadeTime = 0.6})
    Warp.Signal("CalculateWalkSpeed"):Fire(character)
    Warp.Signal("CalculateFov"):Fire()
end

function Block.End(character: Model)
    character:SetAttribute("Blocking", false)
    Warp.Signal("StopAnimation"):Fire(ReplicatedStorage.Animations.Block)
    Warp.Signal("CalculateWalkSpeed"):Fire(character)
    Warp.Signal("CalculateFov"):Fire()
end

return Block