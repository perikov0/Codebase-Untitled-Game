local DummyHandler = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Shared.Utility)

local function SetupDummy(dummy: Model & {Humanoid: Humanoid, HumanoidRootPart: Part}): ()
    dummy.HumanoidRootPart:AddTag("Entity")

    local highlight = Instance.new("Highlight")
    highlight.Adornee = dummy
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 1
    highlight.FillColor = Color3.fromRGB(208, 89, 89)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.Parent = dummy
    highlight.Name = "DamageHighlight"

    local guardBreakUI = ReplicatedStorage.Interface.GuardUI:Clone()
    guardBreakUI.Parent = dummy

    local animator = dummy.Humanoid.Animator

    local blockAnim = animator:LoadAnimation(ReplicatedStorage.Animations.Block)
    local blockBreakAnim = animator:LoadAnimation(ReplicatedStorage.Animations.BlockBreak)
    blockBreakAnim.Priority = Enum.AnimationPriority.Action2

    local blockHealthCapacity = dummy:GetAttribute("BlockHealthCapacity")

    dummy:GetAttributeChangedSignal("BlockHealth"):Connect(function()
        if dummy:GetAttribute("BlockHealth") <= 0 then
            dummy:SetAttribute("Blocking", false)

            blockBreakAnim:Play(.1)
            Utility.FireAllInRadius(ReplicatedStorage.Network.ExecuteCombatFunction, dummy.HumanoidRootPart.Position, 80)
            task.wait(blockBreakAnim.Length)

            dummy:SetAttribute("Blocking", true)
            dummy:SetAttribute("BlockHealth", blockHealthCapacity)
        end

        local blockPercentage = dummy:GetAttribute("BlockHealth")/dummy:GetAttribute("BlockHealthCapacity")
        Utility.CutOffImage(guardBreakUI.Fill, blockPercentage, {Rotation = 270})
    end)

    guardBreakUI.Enabled = dummy:GetAttribute("Blocking")

    dummy:GetAttributeChangedSignal("Blocking"):Connect(function()
        local isBlocking = dummy:GetAttribute("Blocking")
        guardBreakUI.Enabled = isBlocking

        if isBlocking then
            blockAnim:Play(0.2)
        else
            blockAnim:Stop(0.1)
        end
    end)
end

function DummyHandler.ServerInit()
    DummyHandler.Dummies = {}

    local dummiesFolder: Folder = workspace.Dummies

    for _, dummyModel in dummiesFolder:GetChildren() do
        SetupDummy(dummyModel)
    end

    dummiesFolder.ChildAdded:Connect(SetupDummy)
end

return DummyHandler