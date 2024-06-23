local MovementController = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Configs = ReplicatedStorage.Configs

local Warp = require(ReplicatedStorage.Packages.Warp)
local Trove = require(ReplicatedStorage.Packages.Trove)

function MovementController.CharacterInit(character: Model)
    MovementController.Trove:Clean()

    MovementController.Character = character
    MovementController.Humanoid = character:WaitForChild("Humanoid")

    local hrp = character:WaitForChild("HumanoidRootPart")
    MovementController.Trove:Add(RunService.Heartbeat:Connect(function()
        local direction = MovementController.GetDirection(hrp.CFrame.LookVector, MovementController.Humanoid.MoveDirection.Unit)
        character:SetAttribute("Direction", direction)
    end))
    task.wait(.1)
    MovementController.StopRun() --// Initialize as not running.
end

function MovementController.GetDirection(relativeFromVector: Vector3, relativeToVector: Vector3): string
    local dotProduct = math.clamp(relativeFromVector:Dot(relativeToVector), -1, 1)
    local sideProduct = math.clamp(relativeFromVector:Dot(relativeToVector:Cross(Vector3.new(0,1,0))), -1, 1)

    if dotProduct >= 0.5 then
        return "Forwards"
    end

    if dotProduct <= -0.5 then
        return "Backwards"
    end

    if dotProduct < 0.5 and dotProduct > -0.5 then
        return if sideProduct > 0 then "Left" else "Right"
    end

    return "Forwards"

end

function MovementController.PlayerInit()
    MovementController.Trove = Trove.new()
end

function MovementController.BeginRun()
    Warp.Signal("PlayAnimation"):Fire(ReplicatedStorage.Animations.Run, {FadeTime = 0.15, StopGroup = "DirectionWalk"})
    MovementController.Character:SetAttribute("Running", true)
    MovementController.CalculateWalkSpeed()
    Warp.Signal("CalculateFov"):Fire()
end

function MovementController.StopRun()
    Warp.Signal("StopAnimation"):Fire(ReplicatedStorage.Animations.Run, {FadeTime = 0.4})
    MovementController.Character:SetAttribute("Running", false)
    MovementController.CalculateWalkSpeed()
    Warp.Signal("CalculateFov"):Fire()
end

local function StopRunning()
    MovementController.Running = false
    MovementController.StopRun()
end

local function StartRunning()
    MovementController.Running = true
    MovementController.BeginRun()
end

function MovementController.CalculateWalkSpeed()
    local character = MovementController.Character
    local humanoid: Humanoid = MovementController.Humanoid
    local calculatedSpeed = Configs.WalkSpeed.Value

    if character:GetAttribute("Running") then
        calculatedSpeed = Configs.RunSpeed.Value
    end

    if character:GetAttribute("Blocking") then
        calculatedSpeed = Configs.BlockWalkSpeed.Value
    end

    humanoid.WalkSpeed = calculatedSpeed
end

function MovementController.OnMovementKey()
    if not MovementController.Character then return end
end

Warp.Signal("OnMovementKey"):Connect(MovementController.OnMovementKey)
Warp.Signal("StopRunning"):Connect(StopRunning)
Warp.Signal("StartRunning"):Connect(StartRunning)
Warp.Signal("CalculateWalkSpeed"):Connect(MovementController.CalculateWalkSpeed)

return MovementController
