local Crouch = {}
Crouch.DataName = "Crouch"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Warp = require(ReplicatedStorage.Packages.Warp)

function Crouch.Begin(character: Model)
    character:SetAttribute("Crouching", true)
    Warp.Signal("CalculateWalkSpeed"):Fire(character)
    Warp.Signal("CalculateFov"):Fire()
end

function Crouch.End(character: Model)
    character:SetAttribute("Crouching", false)
    Warp.Signal("CalculateWalkSpeed"):Fire(character)
    Warp.Signal("CalculateFov"):Fire()
end

return Crouch