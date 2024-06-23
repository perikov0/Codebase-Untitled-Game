local CameraController = {}

local CurrentCamera = workspace.CurrentCamera

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Warp = require(ReplicatedStorage.Packages.Warp)
local WarpKeys = require(ReplicatedStorage.WarpKeys)

local SmoothShiftLock = require(ReplicatedStorage.Packages.SmoothShiftLock)
local CameraShaker = require(ReplicatedStorage.Packages.CameraShake)

local Sensitivity = 1/100

local Configs = ReplicatedStorage.Configs

local BlockFovTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local RunningFovTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local WalkFovTweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function CameraController.CharacterInit(character: Model)
	CameraController.Character = character
	CameraController.Humanoid = character:WaitForChild("Humanoid")
end

function CameraController.PlayerInit()
	SmoothShiftLock.Init()
	CurrentCamera.FieldOfView = Configs.DefaultFov.Value

	RunService:BindToRenderStep("TrackHead", Enum.RenderPriority.Camera.Value, function()
		local character = CameraController.Character
		local humanoid = CameraController.Humanoid
		if (not character) or (not humanoid) then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		local head = character:WaitForChild("Head")
		local leftUpperArm = character:WaitForChild("LeftUpperArm")
		local rightUpperArm = character:WaitForChild("LeftUpperArm")

		local averagePosition = (head.Position+root.Position+rightUpperArm.Position+leftUpperArm.Position)/4
		local offset = (root.CFrame + Vector3.new(0, 1.5, 0)):PointToObjectSpace(averagePosition+Vector3.new(0,1.2,0))
		offset -= root.CFrame:PointToObjectSpace(root.Position+root.AssemblyLinearVelocity*Sensitivity)
		humanoid.CameraOffset = humanoid.CameraOffset:Lerp(offset,.03)
	end)

	CameraController.CameraShaker = CameraShaker.new(Enum.RenderPriority.Camera.Value, "CameraShake", function(shake)
		CurrentCamera.CFrame = CurrentCamera.CFrame * shake
	end)

	CameraController.CameraShaker:Start()

end

local function CalculateFov()
	local character = CameraController.Character

	if CameraController.CurrentFOVTween then
		CameraController.CurrentFOVTween:Pause()
	end

	local fov = Configs.DefaultFov.Value
	local fovTweenInfo = WalkFovTweenInfo

	if character:GetAttribute("Running") then
		fov = Configs.DefaultFov.Value*1.03
		fovTweenInfo = RunningFovTweenInfo
	end

	if character:GetAttribute("Blocking") then
		fov = Configs.DefaultFov.Value*0.98
		fovTweenInfo = BlockFovTweenInfo
	end

	CameraController.CurrentFOVTween = TweenService:Create(CurrentCamera, fovTweenInfo, {FieldOfView = fov})
	CameraController.CurrentFOVTween:Play()

	return CameraController.CurrentFOVTween
end

local function ShakeCamera(mode: "Once" | "Sustain", ...)
	if mode == "Once" then
		CameraController.CameraShaker:ShakeOnce(...)
	elseif mode == "Sustain" then
		CameraController.CameraShaker:ShakeSustain(...)
	end
end

WarpKeys.Client.CalculateFov = Warp.Signal("CalculateFov"):Connect(CalculateFov)
Warp.Signal("ShakeCamera"):Connect(ShakeCamera)

return CameraController