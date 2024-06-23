local M1 = {}
M1.DataName = "M1"
M1.DamageHighlights = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Utility = require(ReplicatedStorage.Shared.Utility)

local Warp = require(ReplicatedStorage.Packages.Warp)
local WarpKeys = require(ReplicatedStorage.WarpKeys)

local highlightTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

function M1.Begin(character: Model)
	if character:GetAttribute("ServerCanM1") == false then return end
	print("Client M1")

	task.spawn(function()
		ReplicatedStorage.Network.ExecuteCombatFunction:FireServer(workspace:GetServerTimeNow(), "M1", Enum.UserInputState.Begin)
	end)

	local prevIndex = character:GetAttribute("CombatIndex")
	character:SetAttribute("ServerCanM1", false)
	character:SetAttribute("CombatIndex", if prevIndex < 5 then prevIndex%5+1 else 1)
	print("Client Sync:", character:GetAttribute("CombatIndex"))

	local animationInstance = ReplicatedStorage.Animations.RegularM1s[character:GetAttribute("CombatIndex")]

	local animation: AnimationTrack = Warp.Signal("GetAnimation"):Invoke(WarpKeys.Client.GetAnimation, animationInstance)
	animation:Play(.2)
end

function M1.ReplicateVFX(_, _, hitEntities)
	for _, entityRoot: Part in hitEntities do
		local entityModel = entityRoot.Parent

		local highlight = entityModel:FindFirstChild("DamageHighlight")
		if not highlight then return end --// Means the target isn't properly loaded

		if M1.DamageHighlights[highlight] then
			M1.DamageHighlights[highlight]:Cancel()
			M1.PrevCompletedConn:Disconnect()
		end

		M1.DamageHighlights[highlight] = TweenService:Create(highlight, highlightTweenInfo, {FillTransparency = 0.6, OutlineTransparency = 0.4})
		M1.DamageHighlights[highlight]:Play()

		M1.PrevCompletedConn = M1.DamageHighlights[highlight].Completed:Once(function()
			M1.DamageHighlights[highlight] = TweenService:Create(highlight, highlightTweenInfo, {FillTransparency = 1, OutlineTransparency = 1})
			M1.DamageHighlights[highlight]:Play()
		end)

		local hitVFX: Part = ReplicatedStorage.VFX.HitVFX

		if entityModel:GetAttribute("Blocking") then
			hitVFX = ReplicatedStorage.VFX.BlockHitVFX
		end

		hitVFX = hitVFX:Clone()
		hitVFX.CFrame = entityRoot.CFrame
		hitVFX.Parent = workspace.Effects

		Utility.Emit(hitVFX)
	end
end

return M1