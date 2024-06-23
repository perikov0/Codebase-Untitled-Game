local Roll = {}
Roll.DataName = "Roll"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Warp = require(ReplicatedStorage.Packages.Warp)
local Configs = ReplicatedStorage.Configs

function Roll.Begin(character: Model)
    if character:GetAttribute("CanRoll") == false then return end

    character:SetAttribute("Rolling", true)
    character:SetAttribute("CanRoll", false)

    local direction = character:GetAttribute("Direction") or "Forwards"

    local humanoidRootPart: Part = character:WaitForChild("HumanoidRootPart")

    Warp.Signal("PlayAnimation"):Fire(ReplicatedStorage.Animations.Rolls[direction], {AnimationPriority = Enum.AnimationPriority.Action2})
    local Vector = humanoidRootPart.CFrame.LookVector
    if direction == "Backwards" then
        Vector = -humanoidRootPart.CFrame.LookVector
    elseif direction == "Left" then
        Vector = -humanoidRootPart.CFrame.RightVector*0.9
    elseif direction == "Right" then
        Vector = humanoidRootPart.CFrame.RightVector*0.9
    end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector*Configs.RollVelocity.Value
    bodyVelocity.MaxForce = Vector3.new(8e6,0,8e6)
    bodyVelocity.Name = "RollVelocity"
    bodyVelocity.Parent = humanoidRootPart

    task.delay(.15, function()
        local tween = TweenService:Create(bodyVelocity, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {Velocity = bodyVelocity.Velocity*0.5})
        tween:Play()

        tween.Completed:Once(function()
            bodyVelocity:Destroy()
            character:SetAttribute("Rolling", false)
            task.wait(Configs.RollCooldown.Value)
            character:SetAttribute("CanRoll", true)
        end)
    end)

end

return Roll