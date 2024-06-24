local GuardBreakVFX = {}
GuardBreakVFX.DataName = "GuardBreakVFX"
GuardBreakVFX.CachedAnimations = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(ReplicatedStorage.Shared.Utility)

local function Debris(particle: Part, debrisTime: number)
    task.delay(debrisTime, particle.Destroy, particle)
end

function GuardBreakVFX.ReplicateVFX(_, _, dummy)
	local GuardBreakParticle = ReplicatedStorage.VFX.GuardBreakVFX:Clone()
    GuardBreakParticle.CFrame = dummy.HumanoidRootPart.CFrame
    GuardBreakParticle.Parent = workspace.Effects
    Debris(GuardBreakParticle, 2)
    Utility.Emit(GuardBreakParticle)

    local dummyAnimator: Animator = dummy:WaitForChild("Humanoid"):WaitForChild("Animator")
    local blockBreakAnim = GuardBreakVFX.CachedAnimations[dummy] or dummyAnimator:LoadAnimation(ReplicatedStorage.Animations.BlockBreak)
    blockBreakAnim:Play(.1)
    GuardBreakVFX.CachedAnimations[dummy] = blockBreakAnim
end

return GuardBreakVFX